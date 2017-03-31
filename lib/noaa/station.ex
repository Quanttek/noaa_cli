defmodule NOAA.Station do
  alias NOAA.Station.XMLParser
  alias NOAA.Station

  defstruct [id: "", state: "", name: "", latitude: 0.0, longitude: 0.0]

  def parse_keywords([], struct) do
    struct
  end

  def parse_keywords(list, struct) do
    Enum.reduce(list, struct, &parse_keyword(&1, &2))
  end

  defp parse_keyword({:id, id}, struct = %Station{}),
    do: %Station{struct | id: id}
  defp parse_keyword({:name, name}, struct = %Station{}),
    do: %Station{struct | name: name}
  defp parse_keyword({:state, state}, struct = %Station{}),
    do: %Station{struct | state: state}
  defp parse_keyword({:latitude, latitude}, struct = %Station{}),
    do: %Station{struct | latitude: latitude}
  defp parse_keyword({:longitude, longitude}, struct = %Station{}),
    do: %Station{struct | longitude: longitude}
  defp parse_keyword(_, struct = %Station{}),
    do: struct

  def get_matching_stations(user_input_struct = %Station{}) do
    user_input_struct
    |> Map.from_struct()
    |> Enum.filter(fn {_key, value} -> not value in ["", 0.0] end)
    |> Enum.into(%{})
    |> XMLParser.match_user_input_to_stations()
  end
end
