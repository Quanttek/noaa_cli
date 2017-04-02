defmodule NOAA.Station do
  require Logger

  alias NOAA.XMLParser
  alias NOAA.Station

  defstruct [id: "", state: "", name: "", latitude: 0.0, longitude: 0.0]

  #TODO: Refactor: Don't return partially filled station, but instead a map
  def parse_keywords([], struct = %Station{}) do
    struct
  end

  def parse_keywords(list, struct = %Station{}) do
    Enum.reduce(list, struct, &parse_keyword(&1, &2))
  end

  defp parse_keyword({:id, id}, struct),
    do: %Station{struct | id: id}
  defp parse_keyword({:name, name}, struct),
    do: %Station{struct | name: name}
  defp parse_keyword({:state, state}, struct),
    do: %Station{struct | state: state}
  defp parse_keyword({:latitude, latitude}, struct),
    do: %Station{struct | latitude: latitude}
  defp parse_keyword({:longitude, longitude}, struct),
    do: %Station{struct | longitude: longitude}
  defp parse_keyword(_, struct),
    do: struct

  def get_matching(user_input_struct = %Station{}) do
    user_input_struct
    |> Map.from_struct()
    |> Enum.filter(fn {_key, value} -> not value in ["", 0.0] end)
    |> Enum.into(%{})
    |> match_user_input_to_stations()
  end

  def match_user_input_to_stations(user_input_map) do
    {:ok, xml_string} = NOAA.WebHandler.fetch_list
    station_list = XMLParser.parse_station_list(xml_string)

    get_fully_matching(station_list, user_input_map)
  end

  def get_fully_matching(station_list, key_map)
    when map_size(key_map) == 0 do
    station_list
  end

  def get_fully_matching(station_list, key_map =
      %{latitude: latitude, longitude: longitude}) do
    key_map = key_map
    |> Map.delete(:latitude)
    |> Map.delete(:longitude)

    station_list
    |> get_key_matching([latitude: latitude, longitude: longitude])
    |> List.flatten
    |> get_fully_matching(key_map)
  end

  def get_fully_matching(station_list, key_map) do
    key = List.first(Map.keys(key_map))
    {value, key_map} = Map.pop(key_map, key)

    station_list
    |> get_key_matching([{key, value}])
    |> List.flatten
    |> get_fully_matching(key_map)
  end

  def get_key_matching(station_list, [{key, value}]) do
    Enum.filter(station_list, &match_for_key_value(&1, [{key, value}]))
  end

  def get_key_matching(station_list, [latitude: latitude, longitude: longitude]) do
    for station <- station_list,
        match_for_key_value(station, [latitude: latitude]),
        match_for_key_value(station, [longitude: longitude]),
        do: station
  end

  defp match_for_key_value(station = %Station{}, [id: value]) do
    if station.id == value, do: station
  end

  defp match_for_key_value(station = %Station{}, [state: value]) do
    state = station.state
    cond do
      state == value and String.length(value) == 2 #When the user uses state abbreviations
        -> station
      match_abbr_to_state(station.state) == value
        -> station
      true
        -> nil
    end
  end

  defp match_for_key_value(station = %Station{}, [name: value]) do
    if String.match?(value, ~r{#{station.name}}), do: station
  end

  defp match_for_key_value(station = %Station{}, [latitude: value]) do
    if abs(station.latitude - value) <= 1.0, do: station
  end

  defp match_for_key_value(station = %Station{}, [longitude: value]) do
    if abs(station.longitude - value) <= 1.0, do: station
  end

  defp match_for_key_value(_station, _key_and_value) do
    nil
  end

  defp match_abbr_to_state(abbr) do
    abbr_to_state = %{
      "AL" => "Alabama",
      "AK" => "Alaska",
      "AZ" => "Arizona",
      "AR" => "Arkansas",
      "CA" => "California",
      "CO" => "Colorado",
      "CT" => "Connecticut",
      "DE" => "Delaware",
      "DC" => "Washington D.C.",
      "FL" => "Florida",
      "GA" => "Georgia",
      "HI" => "Hawaii",
      "ID" => "Idaho",
      "IL" => "Illinois",
      "IN" => "Indiana",
      "IA" => "Iowa",
      "KS" => "Kansas",
      "US" => "Kentucky",
      "LA" => "Louisiana",
      "ME" => "Maine",
      "MD" => "Maryland",
      "MA" => "Massachusetts",
      "MI" => "Michigan",
      "MN" => "Minnesota",
      "MS" => "Mississippi",
      "MO" => "Missouri",
      "MT" => "Montana",
      "NE" => "Nebraska",
      "NV" => "Nevada",
      "NH" => "New Hampshire",
      "NJ" => "New Jersey",
      "NM" => "New Mexico",
      "NY" => "New York",
      "NC" => "North Carolina",
      "ND" => "North Dakota",
      "OH" => "Ohio",
      "OK" => "Oklahoma",
      "OR" => "Oregon",
      "PA" => "Pennsylvania",
      "RI" => "Rhode Island",
      "SC" => "South Carolina",
      "SD" => "South Dakota",
      "TN" => "Tennessee",
      "TX" => "Texas",
      "UT" => "Utah",
      "VT" => "Vermont",
      "VA" => "Virginia",
      "WA" => "Washington",
      "WV" => "West Virginia",
      "WI" => "Wisconsin",
      "WY" => "Wyoming",
      #U.S. Territories
      "AS" => "American Samoa",
      "GU" => "Guam",
      "MP" => "Northern Mariana Islands",
      "PR" => "Puerto Rico",
      "VI" => "U.S. Virgin Islands",
      "UM" => "U.S. Minor Outlying Islands", #Currently no stations exist here
      #Canada
      "AB" => "Alberta",
      "BC" => "British Columbia",
      "MB" => "Manitoba",
      "NB" => "New Brunswick",
      "NF" => "Newfoundland and Labrador",
      "NS" => "Nova Scotia",
      "NT" => "Northwest Territories",
      "NU" => "Nunavut",
      "ON" => "Ontario",
      "PE" => "Prince Edward Island",
      "QC" => "Quebec",
      "SK" => "Saskatchewan",
      "YT" => "Yukon",
    }
    case Map.fetch(abbr_to_state, abbr) do
      {:ok, state} -> state
      :error -> Logger.error("Could not find state with abbreviation #{abbr}")
    end
  end
end
