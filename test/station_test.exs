defmodule StationTest do
  use ExUnit.Case
  #doctest Noaa

  import Noaa.Station, only: [parse_keywords: 2,
                              get_key_matching: 2,
                              get_fully_matching: 2]
  alias Noaa.Station

  def station_list do
    [%Station{id: "CWAV", state: "AB", name: "Sundre",
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
  end

  ########################
  #parse_keywords/2 tests#
  ########################

  test "Get correcty partially filled %Station{} from user input (1/2)" do
    user_input = [id: "ABCD", state: "BC"]

    expected_result = %Station{id: "ABCD", state: "BC", name: "",
                               latitude: 0.0, longitude: 0.0}

    assert(parse_keywords(user_input, %Station{}) == expected_result)
  end

  test "Get correcty partially filled %Station{} from user input (2/2)" do
    user_input = [latitude: 75.1, longitude: -100]

    expected_result = %Station{id: "", state: "", name: "",
                               latitude: 75.1, longitude: -100}

    assert(parse_keywords(user_input, %Station{}) == expected_result)
  end

  test "Get empty %Station{} from no user input" do
    user_input = []

    expected_result = %Station{id: "", state: "", name: "",
                               latitude: 0.0, longitude: 0.0}

    assert(parse_keywords(user_input, %Station{}) == expected_result)
  end

  #####################################
  #get_fully_matching/2 tests#
  #####################################

  test "Get correct fully matching stations with state and longitude from station list" do
    key_map = %{longitude: -114, state: "AB"}

    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                                latitude: 51.76667, longitude: -114.68333}]

    assert(get_fully_matching(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with state and name from station list" do
    key_map = %{state: "MD", name: "Baltimore / Martin"}

    expected_result = [%Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                                latitude: 39.33333, longitude: -76.41667}]

    assert(get_fully_matching(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with latitude and longitude from station list" do
    key_map = %{longitude: -76, latitude: 39}

    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667},
                      %Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_fully_matching(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with latitude, longitude and state from station list" do
    key_map = %{longitude: -76, latitude: 39, state: "DE"}

    expected_result = [%Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_fully_matching(station_list(), key_map) == expected_result)
  end

  ###################################
  #get_key_matching/2 tests#
  ###################################

  test "Get correct id matching station from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                                latitude: 39.08333, longitude: -76.76667}]

    assert(get_key_matching(station_list(), [id: "KFME"]) == expected_result)
  end

  test "Get correct state matching stations from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667}]

    assert(get_key_matching(station_list(), [state: "MD"]) == expected_result)
  end

  test "Get correct name matching station from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                                latitude: 51.76667, longitude: -114.68333}]

    assert(get_key_matching(station_list(), [name: "Sundre"]) == expected_result)
  end

  test "Get correct latitude and longitude matching stations from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667},
                      %Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_key_matching(station_list(), [latitude: 39, longitude: -76])
      == expected_result)
  end

  test "Get correct latitude matching stations from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                        latitude: 51.76667, longitude: -114.68333},
                      %Station{id: "CWDZ", state: "AB", name: "Drumheller East",
                        latitude: 51.44504, longitude: -112.69654}]

    assert(get_key_matching(station_list(), [latitude: 51])
      == expected_result)
  end

  test "Get correct longitude matching stations from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                        latitude: 51.76667, longitude: -114.68333},
                      %Station{id: "CWDZ", state: "AB", name: "Drumheller East",
                        latitude: 51.44504, longitude: -112.69654},
                      %Station{id: "KMSO", state: "MT", name: "Missoula, Missoula International Airport",
                        latitude: 46.92083, longitude: -114.0925}]

    assert(get_key_matching(station_list(), [longitude: -113.69])
      == expected_result)
  end
end
