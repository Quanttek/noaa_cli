defmodule Noaa.XMLParser do
  import SweetXml

  alias Noaa.Station
  alias Noaa.Weather

  require Logger

  def parse_station_list(xml_string) do
    xml_string
    |> xpath(~x"//station"l)
    |> Enum.map(fn station ->
      %Station{
        id:         xpath(station, ~x"./station_id/text()")   |> to_string(),
        name:       xpath(station, ~x"./station_name/text()") |> to_string(),
        state:      xpath(station, ~x"./state/text()")        |> to_string(),
        latitude:   xpath(station, ~x"./latitude/text()")     |> list_to_num(),
        longitude:  xpath(station, ~x"./longitude/text()")    |> list_to_num(),
      }
    end)
  end

  def parse_station(xml_string) do
    xml_string
    |> xpath(~x"//current_observation")
    |> (fn(station) ->
      %Weather{
        last_updated: xpath(station, ~x"./observation_time/text()")
          |> to_string() |> del_half(",", :left) |> String.trim(),
        weather: xpath(station, ~x"./weather/text()")
          |> to_string(),
        temp: xpath(station, ~x"./temp_f/text()")
          |> to_string(),
        humidity: xpath(station, ~x"./relative_humidity/text()")
          |> to_string(),
        wind: "#{xpath(station, ~x"./wind_dir/text()")
        |> to_string()} at #{xpath(station, ~x"./wind_mph/text()")
        |> to_string()} MPH",
        #alternative:
        #xpath(station, ~x"./wind_string/text()")
        #  |> to_string() |> del_half("(", :right) |> String.trim(),
        msl_pressure: xpath(station, ~x"./pressure_mb/text()")
          |> to_string(),
        }
      end).()
  end

  def parse_station_html(html_string) do #Old: Uses document displayed by browser, but access to xml is possible
    html_string
    |> xpath(~x"//body/table/tbody/tr/td[2]/table[1]/tbody/tr/td[2]/table/tbody")
    |> (fn(station) ->
      %Weather{
        last_updated: xpath(station, ~x"./tr[2]/td[2]/text()[1]")
          |> to_string() |> del_half(",", :left) |> String.trim(),   #TODO: Get real timestamp and display "x minutes ago"
        weather: xpath(station, ~x"./tr[3]/td[2]/text()")
          |> to_string() |> del_half("(", :right) |> String.trim(),
        temp: xpath(station, ~x"./tr[4]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> String.trim(),
        humidity: xpath(station, ~x"./tr[6]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> String.trim(),
        wind: xpath(station, ~x"./tr[7]/td[2]/text()")
          |> to_string() |> del_half("(", :right) |> String.trim(),
        msl_pressure: xpath(station, ~x"./tr[10]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> String.trim(),
      }
    end).()
  end

  defp list_to_num(list) when is_list(list) do
    if Enum.any?(list, &(&1 == 46)),
      do: List.to_float(list),
    else: List.to_integer(list)
  end

#  defp string_to_num(string) when is_bitstring(string) do
#    if String.contains?(string, "."),
#      do: String.to_float(string),
#    else: String.to_integer(string)
#  end

  defp del_half(string, pattern, :left) do
    [_left, right] = String.split(string, pattern)
    right
  end

  defp del_half(string, pattern, :right) do
    [left, _right] = String.split(string, pattern)
    left
  end
end
