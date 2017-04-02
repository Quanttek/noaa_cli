defmodule NOAA.XMLParser do
  alias NOAA.Station
  import SweetXml
  require Logger

  def parse_station_list(xml_string) do
    xml_string
    |> xpath(~x"//station"l)
    |> Enum.map(fn station ->
      %Station{
        id: xpath(station, ~x"./station_id/text()") |> to_string,
        state: xpath(station, ~x"./state/text()") |> to_string,
        name: xpath(station, ~x"./station_name/text()") |> to_string,
        latitude: xpath(station, ~x"./latitude/text()") |> list_to_num,
        longitude: xpath(station, ~x"./longitude/text()") |> list_to_num,
      }
    end)
  end

  def parse_station(html_string) do
    html_string
    |> xpath(~x"")
  end

  defp list_to_num(list) when is_list(list) do
    if Enum.any?(list, &(&1 == 46)) do
      List.to_float(list)
    else
      List.to_integer(list)
    end
  end
end
