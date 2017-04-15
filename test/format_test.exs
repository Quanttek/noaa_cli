defmodule FormatTest do
  use ExUnit.Case

  import Noaa.Format, only: [fix_cell_widths: 2,
                             create_station_list: 1,
                             create_weather_list: 1,
                             create_table: 1]

  alias Noaa.Station
  alias Noaa.Weather

  test "Create correct weather table" do
    list = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                     latitude: 39.08333, longitude: -76.76667},
            %Weather{last_updated: "6:39 am EDT", weather: "Fair",
                     temp: "54.0", humidity: "88", wind: "Calm",
                     msl_pressure: nil}]

    expected_result = """
    KFME | Fort Meade / Tipton | MD | 39.08333 N | 76.76667 W
    ☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀☀
      Updated at | 6:39 am EDT
         Weather | Fair\s\s\s\s\s\s\s
      Temp. (°F) | 54.0\s\s\s\s\s\s\s
    Humidity (%) | 88\s\s\s\s\s\s\s\s\s
            Wind | Calm\s\s\s\s\s\s\s
    """

    assert((create_table(list) <> "\n") == expected_result)
  end

  test "Create correct station list" do
    list = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                     latitude: 39.08333, longitude: -76.76667},
            %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                     latitude: 39.33333, longitude: -76.41667},
            %Station{id: "KMSO", state: "MT", name: "Missoula, Missoula International Airport",
                     latitude: 46.92083, longitude: -114.0925}]

    expected_result = """
    #    | Name                                     | State | Latitude   | Longitude\s
    -----+------------------------------------------+-------+------------+-----------
    KFME | Fort Meade / Tipton                      | MD    | 39.08333 N | 76.76667 W
    KMTN | Baltimore / Martin                       | MD    | 39.33333 N | 76.41667 W
    KMSO | Missoula, Missoula International Airport | MT    | 46.92083 N | 114.0925 W
    """

    assert((create_table(list) <> "\n") == expected_result)
  end

  test "Create correct station table list" do
    station_list = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                             latitude: 51.76667, longitude: -114.68333},
                    %Station{id: "CWDZ", state: "AB", name: "Drumheller East",
                             latitude: 51.44504, longitude: -112.69654}, #longitude value is modified
                    %Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                             latitude: 39.08333, longitude: -76.76667},
                    %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                             latitude: 39.33333, longitude: -76.41667},
                    %Station{id: "KMSO", state: "MT", name: "Missoula, Missoula International Airport",
                             latitude: 46.92083, longitude: -114.0925},
                    %Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                             latitude: 39.13333, longitude: -75.46667}]

    expected_result = [["CWAV", "Sundre", "AB", "51.76667 N", "114.68333 W"],
      ["CWDZ", "Drumheller East", "AB", "51.44504 N", "112.69654 W"],
      ["KFME", "Fort Meade / Tipton", "MD", "39.08333 N", "76.76667 W"],
    ["KMTN", "Baltimore / Martin", "MD", "39.33333 N", "76.41667 W"],
      ["KMSO", "Missoula, Missoula International Airport", "MT", "46.92083 N", "114.0925 W"],
      ["KDOV", "Dover Air Force Base", "DE", "39.13333 N", "75.46667 W"]]

    assert(create_station_list(station_list) == expected_result)
  end

  test "Create correct weather table list" do
    weather_list = %Weather{last_updated: "6:39 am EDT", weather: "Fair",
                             temp: "54.0", humidity: "88", wind: "Calm",
                             msl_pressure: nil}

    expected_result = [["Updated at", "6:39 am EDT"],
                       ["Weather", "Fair"],
                       ["Temp. (°F)", "54.0"],
                       ["Humidity (%)", "88"],
                       ["Wind", "Calm"]]

    assert(create_weather_list(weather_list) == expected_result)
  end

  test "Correctly pad a table list (list of rows, which themselves can be lists (columns))" do
    table_list = [["1234567890", "123456", "12345678"],
                  "----------------------------------",
                  "some simple text",
                  ["1234567", "1234567890", "123456"],
                  ["1234567890", "1234", "1234567"]]
    expected_result = [["1234567890", "123456    ", "12345678"],
                       "----------------------------------",
                       "some simple text                  ",
                       ["1234567   ", "1234567890", "123456  "],
                       ["1234567890", "1234      ", "1234567 "]]

    assert(fix_cell_widths(table_list, [[:right]]) == expected_result)
  end
end
