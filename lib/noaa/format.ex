defmodule NOAA.Format do
  alias NOAA.Weather
  alias NOAA.Station

  @labels_station [id: "#", name: "Name", state: "State",
    latitude: "Latitude", longitude: "Longitude"]
  @labels_weather [last_updated: "Updated at", weather: "Weather",
    temp: "Temp. (°F)", humidity: "Humidity (%)", wind: "Wind",
    msl_pressure: "MSL Pressure (mbar)"]
  @total_width 100
  @separator " | "

  def create_row_list(list) do
    Enum.map(list, &do_create_row_list/1)
  end

  defp do_create_row_list(list) when is_list(list) do
    Enum.join(list, @separator)
  end

  defp do_create_row_list(row) do
    row
  end

  def fix_cell_width(table_list) do
    widths = get_column_widths(table_list)
    Enum.map(table_list, &do_fix_cell_width(&1, widths))
  end

  defp do_fix_cell_width(list, widths) when length(list) == length(widths) do
    width_list = Enum.zip(list, widths)
    Enum.map(width_list, fn({elem, width}) ->
      adjust_string_length(elem, width)
    end) #TODO: Pad right-side values of weather display on the left
  end

  #TODO: Maybe create a case where list = list but length don't match. Needed??
  defp do_fix_cell_width(string, _widths) when is_bitstring(string) do
    adjust_string_length(string, @total_width)
  end

  def create_table_list([station = %Station{}, weather = %Weather{}]) do
    weather_list = @labels_weather
      |> Keyword.keys()
      |> Enum.map(&( [&1, Map.fetch!(weather, &1)] )) #label-value pair
      |> Enum.filter(fn([_key, value]) -> value != nil end)
      |> add_labels()
    station_list = create_table_list(station)

    [station_list, get_emoji_separator(weather) | weather_list]
  end

  def create_table_list(station = %Station{}) do
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

  def create_table_list(station_list) when is_list(station_list) do
    Enum.map(station_list, &create_table_list/1)
  end

  def add_separator(list) do
    Enum.join(list, " | ")
  end

  def add_header(station_list) do #FIXME
    keys = %NOAA.Station{} |> Map.from_struct() |> Map.keys()
    Enum.map(keys, &(@labels_station[&1])) ++ station_list
  end

  def add_labels(weather_list) do
    Enum.map(weather_list, fn([key, value]) ->
      [@labels_weather[key], value]
    end)
  end

  def get_emoji_separator(weather = %Weather{}) do
    Weather.get_emoji(weather)
    |> List.duplicate(@total_width)
    |> Enum.join("")
  end

  def get_column_widths(table_list) do
    column_widths = get_max_column_widths(table_list)
    separator_space = (length(column_widths) - 1) * String.length(@separator)
    last_width = (List.last(column_widths) + Enum.reduce(column_widths, @total_width, &(&2 - &1))) -
                  separator_space #Factor in separator space
    List.replace_at(column_widths, length(column_widths) - 1, last_width)
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

  def get_length_of_nth_elem(list, index) when is_list(list) do
    list |> Enum.at(index) |> String.length
  end

  def get_length_of_nth_elem(_string, _index) do #Return zero if not list
    0
  end

  def adjust_string_length(string, length, side \\ :right)

  def adjust_string_length(string, length, :right) do
    if length >= String.length(string) do
      String.pad_trailing(string, length)
    else
      {_left, right} = String.split_at(string, length)
      right
    end
  end

  def adjust_string_length(string, length, :left) do
    if length >= String.length(string) do
      String.pad_trailing(string, length)
    else
      {left, _right} = String.split_at(string, -length)
      left
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
