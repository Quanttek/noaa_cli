defmodule NOAA.Station.XMLparser do
  alias NOAA.Station
  import SweetXml

  #See station struct
  def find_missing_values(struct = %Station{}, keys) do
    xml_string = fetch_list
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

  def fetch_list do

  end
end
