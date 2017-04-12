defmodule FormatTest do
  use ExUnit.Case

  import NOAA.Format, only: [fix_cell_width: 1,
                           create_table_list: 1]
  alias NOAA.Station
  alias NOAA.Weather

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

    assert(create_table_list(station_list) == expected_result)
  end

  test "Create correct weather table list" do
    list = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                     latitude: 39.08333, longitude: -76.76667},
            %Weather{last_updated: "6:39 am EDT", weather: "Fair",
                     temp: "54.0", humidity: "88", wind: "Calm",
                     msl_pressure: nil}]

    expected_result = [["KFME", "Fort Meade / Tipton", "MD", "39.08333 N", "76.76667 W"],
                       String.pad_trailing("", 100, "☀"),
                       ["Updated at", "6:39 am EDT"],
                       ["Weather", "Fair"],
                       ["Temp. (°F)", "54.0"],
                       ["Humidity (%)", "88"],
                       ["Wind", "Calm"]]

    assert(create_table_list(list) == expected_result)
  end

  test "Correctly pad a table list (list of rows, which themselves can be lists (columns))" do
    table_list = [["1234567890", "123456", "12345678"],
                  "----------------------------------",
                  "some simple text",
                  ["1234567", "1234567890", "123456"],
                  ["1234567890", "1234", "1234567            "]]
    expected_result = [["1234567890", "123456    ", "12345678" |> String.pad_trailing(74)],
                       "----------------------------------   " |> String.pad_trailing(100),
                       "some simple text                     " |> String.pad_trailing(100),
                       ["1234567   ", "1234567890", "123456  " |> String.pad_trailing(74)],
                       ["1234567890", "1234      ", "1234567 " |> String.pad_trailing(74)]]

    assert(fix_cell_width(table_list) == expected_result)
  end
end
