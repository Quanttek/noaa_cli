defmodule NOAA.XMLParser do
  alias NOAA.Station
  alias NOAA.Weather
  import SweetXml
  require Logger

  def parse_station_list(xml_string) do
    xml_string
    |> xpath(~x"//station"l)
    |> Enum.map(fn station ->
      %Station{
        id:         xpath(station, ~x"./station_id/text()")   |> to_string(),
        state:      xpath(station, ~x"./state/text()")        |> to_string(),
        name:       xpath(station, ~x"./station_name/text()") |> to_string(),
        latitude:   xpath(station, ~x"./latitude/text()")     |> list_to_num(),
        longitude:  xpath(station, ~x"./longitude/text()")    |> list_to_num(),
      }
    end)
  end

  def parse_station(html_string) do
    html_string
    |> xpath(~x"//body/table/tbody/tr/td[2]/table[1]/tbody/tr/td[2]/table/tbody/")
    |> fn(station) ->
      %Weather{
        last_updated: xpath(station, ~x"./tr[2]/td[2]/text()[1]")
          |> to_string() |> del_half(",", :left),                 #TODO: Get real timestamp and display "x minutes ago"
        weather: xpath(station, ~x"./tr[3]/td[2]/text()")
          |> to_string() |> del_half("(", :right) |> trim,
        temp: xpath(station, ~x"./tr[4]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> string_to_num(),
        humidity: xpath(station, ~x"./tr[6]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> string_to_num(),
        wind: xpath(station, ~x"./tr[7]/td[2]/text()")
          |> to_string() |> del_half("(", :right) |> trim,
        msl_pressure: xpath(station, ~x"./tr[10]/td[2]/text()")
          |> to_string() |> del_half(" ", :right) |> string_to_num(),
      }
    end
  end

  defp list_to_num(list) when is_list(list) do
    if Enum.any?(list, &(&1 == 46)),
      do: List.to_float(list),
    else: List.to_integer(list)
  end

  defp string_to_num(string) when is_bitstring(string) do
    if String.contains?(string, "."),
      do: String.to_float(string),
    else: String.to_integer(string)
  end

  defp delete_string_section(string, start, stop) do
    with {left, _right} <- String.split_at(string, start),
         {_left, right} <- String.split_at(string, stop),
         do: left <> right
  end

  defp del_half(string, pattern, :left) do
    [_left, right] = String.split(string, pattern)
    right
  end

  defp del_half(string, pattern, :right) do
    [left, _right] = String.split(string, pattern)
    left
  end
end
