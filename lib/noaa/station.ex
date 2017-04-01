defmodule NOAA.Station do
  alias NOAA.Station.XMLParser
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
    |> XMLParser.match_user_input_to_stations()
  end
end
