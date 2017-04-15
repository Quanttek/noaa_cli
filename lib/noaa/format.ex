defmodule Noaa.Format do
  alias Noaa.Weather
  alias Noaa.Station

  @labels_station [id: "#", name: "Name", state: "State",
    latitude: "Latitude", longitude: "Longitude"]
  @labels_weather [last_updated: "Updated at", weather: "Weather",
    temp: "Temp. (°F)", humidity: "Humidity (%)", wind: "Wind",
    msl_pressure: "MSL Pressure (mbar)"]

  @total_width 100

  @col_separator " | "
  @row_separator "-"
  @row_col_junction "-+-"

  def create_table([station = %Station{}, weather = %Weather{}]) do
    weather
    |> create_weather_list()
    |> fix_cell_widths([[:left, :right]])
    |> add_header(station, weather.weather)
    |> create_row_list()
    |> Enum.join("\n")
  end

  def create_table(station_list) when is_list(station_list) do
    list = create_station_list(station_list)
    widths = get_column_widths(list, Keyword.values(@labels_station))

    list
    |> fix_cell_widths(widths, [[:right]])
    |> add_header(widths)
    |> create_row_list()
    |> Enum.join("\n")
  end

  def create_weather_list(weather = %Weather{}) do
    @labels_weather
    |> Keyword.keys()
    |> Enum.map(&( [&1, Map.fetch!(weather, &1)] )) #label-value pair
    |> Enum.filter(fn([_key, value]) -> value != nil and value != "" end)
    |> add_labels()
  end

  def create_station_list(station = %Station{}) do
    keys = @labels_station |> Keyword.keys()
    for key <- keys do
      value = Map.fetch!(station, key)
      case key do
        :latitude   -> num_to_coordinates(value, :lat)
        :longitude  -> num_to_coordinates(value, :long)
        _ -> value
      end
    end
  end

  def create_station_list(station_list) do
    Enum.map(station_list, &create_station_list/1)
  end

  def create_row_list(list) when is_list(list) do
    Enum.map(list, &create_row/1)
  end

  defp create_row(list) when is_list(list) do
    Enum.join(list, @col_separator)
  end

  defp create_row(row) do
    row
  end


  def fix_cell_widths(table_list, directions_table) do
    widths = get_column_widths(table_list, [])
    fix_cell_widths(table_list, widths, directions_table)
  end

  def fix_cell_widths(table_list, widths, directions_table) do
    directions_table = stretch_list_with_last_elem(directions_table, length(table_list))

    row_list = Enum.zip(table_list, directions_table)
    Enum.map(row_list, fn({row, directions_row}) ->
      fix_cell_widths_of_row(row, widths, directions_row)
    end)
  end

#Recursive alternative
#  defp do_fix_cell_widths([row], widths, direction_s) do
#    {directions_row, _direction_s} = List.pop_at(direction_s, 0)#

#    [fix_cell_widths_of_row(row, widths, directions_row)]
#  end#

#  defp do_fix_cell_widths(table_list, widths, direction_list = [directions_row]) do #Matched twice so it can work recurively
#    {row, table_list} = List.pop_at(table_list, 0)#

#    [fix_cell_widths_of_row(row, widths, directions_row) |
#     do_fix_cell_widths(table_list, widths, direction_list)]
#  end#

#  defp do_fix_cell_widths(table_list, widths, directions_table) do
#    {row, table_list} = List.pop_at(table_list, 0)
#    {directions_row, directions_table} = List.pop_at(directions_table, 0)#

#    [fix_cell_widths_of_row(row, widths, directions_row) |
#     do_fix_cell_widths(table_list, widths, directions_table)]
#  end

  defp fix_cell_widths_of_row(list, widths, directions_row) when length(list) == length(widths) do
    directions_row = stretch_list_with_last_elem(directions_row, length(list))

    format_list = Enum.zip([list, widths, directions_row])
    Enum.map(format_list, fn({elem, width, direction}) ->
      adjust_string_length(elem, width, direction)
    end)
  end

  #TODO: Maybe create a case where list = list but lengths don't match. Needed??
  defp fix_cell_widths_of_row(string, widths, _directions_row) when is_bitstring(string) do
    total_width = Enum.sum(widths) + (length(widths) - 1) * String.length(@col_separator)
    adjust_string_length(string, total_width, :right)
  end


  def add_header(station_list, widths) do
    padded_header =
      @labels_station
      |> Keyword.values()
      |> fix_cell_widths_of_row(widths, [:right])

    [padded_header, get_header_separator(widths) | station_list]
  end

  def add_header(weather_list, station = %Station{}, weather_string) do
    station_row = station |> create_station_list |> create_row()
    width = String.length(station_row)

    [station_row, get_emoji_separator(weather_string, width) | weather_list]
  end

  def add_labels(weather_list) do
    Enum.map(weather_list, fn([key, value]) ->
      [@labels_weather[key], value]
    end)
  end

  def get_header_separator(widths) do
    for(width <- widths,
      do: String.pad_trailing("", width, @row_separator))
    |> Enum.join(@row_col_junction)
  end

  def get_emoji_separator(weather_string, width) do
    String.pad_trailing("", width, Weather.get_emoji(weather_string))
  end


  def get_column_widths(table_list, header) do
    column_widths =
      case header do
        [] -> get_max_column_widths(table_list)
        h  -> get_max_column_widths([h | table_list])
    end

    separator_space = (length(column_widths) - 1) * String.length(@col_separator)

    max_width_index =  Enum.find_index(column_widths, &(&1 == Enum.max(column_widths)))
    new_max_width = (Enum.at(column_widths, max_width_index) + Enum.reduce(column_widths, @total_width, &(&2 - &1))) - separator_space

    if new_max_width <= Enum.at(column_widths, max_width_index),
      do: List.replace_at(column_widths, max_width_index, new_max_width),
    else: column_widths

#    new_last_width = (List.last(column_widths) + Enum.reduce(column_widths, @total_width, &(&2 - &1))) - separator_space #Factor in separator space

#    if new_last_width <= List.last(column_widths),
#      do: List.replace_at(column_widths, length(column_widths) - 1, new_last_width),
#    else: column_widths
  end

  defp get_max_column_widths(table_list) do
    #Uses the first element to determine the number of columns. May need change TODO
    num_of_col = table_list |> List.first |> length
    for index <- 0..num_of_col-1 do
      table_list
      |> Enum.max_by(&get_length_of_nth_elem(&1, index)) #Returns the whole sub_list
      |> Enum.at(index)
      |> String.length()
    end
  end

  defp get_length_of_nth_elem(list, index) when is_list(list) do
    list |> Enum.at(index) |> String.length
  end

  defp get_length_of_nth_elem(_string, _index) do #Return zero if not list
    0
  end


  def adjust_string_length(string, length, side \\ :right)

  def adjust_string_length(string, length, :right) do
    if length >= String.length(string) do
      String.pad_trailing(string, length)
    else
      {left, _right} = String.split_at(string, length)
      left
    end
  end

  def adjust_string_length(string, length, :left) do
    if length >= String.length(string) do
      String.pad_leading(string, length)
    else
      {_left, right} = String.split_at(string, -length)
      right
    end
  end

  defp stretch_list_with_last_elem(list, num) do
    case num - length(list) do
      0 -> list
      x when x < 0 -> list
      x -> list ++
            list
            |> List.last()
            |> List.duplicate(x+1)
    end
  end


  defp num_to_coordinates(num, :lat) do
    if num >= 0,
      do: to_string(num) <> " N",
    else: (num |> to_string() |> String.trim("-")) <> " S"
  end

  defp num_to_coordinates(num, :long) do
    if num >= 0,
      do: to_string(num) <> " E",
    else: (num |> to_string() |> String.trim("-")) <> " W"
  end
end
