defmodule NOAA.Station.XMLparser do
  alias NOAA.Station
  import SweetXml
  require Logger

  #See station struct
  def find_missing_values(struct = %Station{}, keys) do
    {:ok, xml_string} = NOAA.WebHandler.fetch_list
    station_list = parse_station_list(xml_string)
  end

  def parse_station_list(xml_string) do
    xml_string
    |> xpath(~x"//station"l)
    |> Enum.map(fn(station) ->
      %Station{
        id: xpath(station, ~x"./station_id/text()"),
        state: xpath(station, ~x"./state/text()"),
        name: xpath(station, ~x"./station_name/text()"),
        latitude: xpath(station, ~x"./latitude/text()"),
        longitude: xpath(station, ~x"./longitude/text()"),
      }
    end)
  end

  def get_matching_stations(station_list, {key, value}) do
    for station <- station_list,
        not station[key] in ["", 0.0],
        do: match_station_for_value(station, {key, value})
  end

  def get_matching_stations(station_list, [latitude: latitude, longitude: longitude]) do
    for station <- station_list,
        match_station_for_value(station, {:latitude, latitude}),
        match_station_for_value(station, {:longitude, longitude})
        do: station
  end

  def match_station_for_value(station, {:id, value}) when station[:id] == value do
    station
  end

  def match_station_for_value(station, {:state, value}) do
    case value do
      station[:state] when String.length(value) == 2 #When the user uses state abbreviations
        -> station
      match_abbr_to_state(station[:state])
        -> station
    end
  end

  def match_station_for_value(station, {:name, value}) do
    if String.match?(value, ~r{#{station[:name]}}) do
      station
    end
  end

  def match_station_for_value(station, {:latitude, value}) do
    if abs(station[:latitude] - value <= 1.0) do
      station
    end
  end

  def match_station_for_value(station, {:longitude, value}) do
    if abs(station[:longitude] - value <= 1.0) do
      station
    end
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
      "AS" => "American Samoa",
      "GU" => "Guam",
      "MP" => "Northern Mariana Islands",
      "PR" => "Puerto Rico",
      "VI" => "U.S. Virgin Islands",
      "UM" => "U.S. Minor Outlying Islands",
      "FM" => "Micronesia",
      "MH" => "Marshall Islands",
      "PW" => "Palau"
    }
    case Map.fetch(abbr_to_state, abbr) do
      {:ok, state} -> state
      :error -> Logger.error("Could not find state with abbreviation #{abbr}")
    end
  end
end
