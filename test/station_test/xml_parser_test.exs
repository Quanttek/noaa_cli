defmodule StationTest.XMLParserTest do
  use ExUnit.Case
  #doctest Noaa

  alias NOAA.Station
  import NOAA.Station.XMLParser, only: [parse_station_list: 1,
                                        get_key_matching_stations: 2,
                                        get_fully_matching_stations: 2]

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

  test "Get correct %Station{} struct for dirty xml snippet string of station list (1/2)" do
    xml_string = "\t<station>\n\t\t<station_id>CWAV</station_id>\n\t\t<state>AB</state>\n            \t<station_name>Sundre</station_name>\n\t\t<latitude>51.76667</latitude>\n\t\t<longitude>-114.68333</longitude>\n            \t<html_url>http://weather.noaa.gov/weather/current/CWAV.html</html_url>\n            \t<rss_url>http://weather.gov/xml/current_obs/CWAV.rss</rss_url>\n            \t<xml_url>http://weather.gov/xml/current_obs/CWAV.xml</xml_url>\n\t</station>\n\n"
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                      latitude: 51.76667, longitude: -114.68333}]

    assert(parse_station_list(xml_string) == expected_result)
  end

  #Test exists to a) check the string_to_num func and b) be sure formatting changes will not affect results
  test "Get correct %Station{} struct for clean xml snippet string of station list (2/2)" do
    xml_string = "<station><station_id>PABI</station_id><state>AK</state><station_name>Delta Junction/Ft Greely, Allen Army Airfield</station_name><latitude>64</latitude><longitude>-145.73333</longitude><html_url>http://weather.noaa.gov/weather/current/PABI.html</html_url><rss_url>http://weather.gov/xml/current_obs/PABI.rss</rss_url><xml_url>http://weather.gov/xml/current_obs/PABI.xml</xml_url></station>"
    expected_result = [%Station{id: "PABI", state: "AK", name: "Delta Junction/Ft Greely, Allen Army Airfield",
                      latitude: 64, longitude: -145.73333}]

    assert(parse_station_list(xml_string) == expected_result)
  end

  test "Get correct %Station{} struct for xml document string of station list" do
    xml_string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<wx_station_index>\n        <credit>NOAA's National Weather Service</credit>\n        <credit_URL>http://weather.gov/</credit_URL>\n        <image>\n                <url>http://weather.gov/images/xml_logo.gif</url>\n                <title>NOAA's National Weather Service</title>\n                <link>http://weather.gov</link>\n        </image>\n        <suggested_pickup>08:00 EST</suggested_pickup>\n        <suggested_pickup_period>1140</suggested_pickup_period>\n\t<station>\n\t\t<station_id>CWAV</station_id>\n\t\t<state>AB</state>\n            \t<station_name>Sundre</station_name>\n\t\t<latitude>51.76667</latitude>\n\t\t<longitude>-114.68333</longitude>\n            \t<html_url>http://weather.noaa.gov/weather/current/CWAV.html</html_url>\n            \t<rss_url>http://weather.gov/xml/current_obs/CWAV.rss</rss_url>\n            \t<xml_url>http://weather.gov/xml/current_obs/CWAV.xml</xml_url>\n\t</station>\n\n</wx_station_index>\n"
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                      latitude: 51.76667, longitude: -114.68333}]

    assert(parse_station_list(xml_string) == expected_result)
  end

  #####################################
  #get_fully_matching_stations/2 tests#
  #####################################

  test "Get correct fully matching stations with state and longitude from station list" do
    key_map = %{longitude: -114, state: "AB"}

    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                                latitude: 51.76667, longitude: -114.68333}]

    assert(get_fully_matching_stations(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with state and name from station list" do
    key_map = %{state: "MD", name: "Baltimore / Martin"}

    expected_result = [%Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                                latitude: 39.33333, longitude: -76.41667}]

    assert(get_fully_matching_stations(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with latitude and longitude from station list" do
    key_map = %{longitude: -76, latitude: 39}

    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667},
                      %Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_fully_matching_stations(station_list(), key_map) == expected_result)
  end

  test "Get correct fully matching stations with latitude, longitude and state from station list" do
    key_map = %{longitude: -76, latitude: 39, state: "DE"}

    expected_result = [%Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_fully_matching_stations(station_list(), key_map) == expected_result)
  end

  ###################################
  #get_key_matching_stations/2 tests#
  ###################################

  test "Get correct id matching station from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                                latitude: 39.08333, longitude: -76.76667}]

    assert(get_key_matching_stations(station_list(), [id: "KFME"]) == expected_result)
  end

  test "Get correct state matching stations from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667}]

    assert(get_key_matching_stations(station_list(), [state: "MD"]) == expected_result)
  end

  test "Get correct name matching station from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                                latitude: 51.76667, longitude: -114.68333}]

    assert(get_key_matching_stations(station_list(), [name: "Sundre"]) == expected_result)
  end

  test "Get correct latitude and longitude matching stations from station list" do
    expected_result = [%Station{id: "KFME", state: "MD", name: "Fort Meade / Tipton",
                        latitude: 39.08333, longitude: -76.76667},
                      %Station{id: "KMTN", state: "MD", name: "Baltimore / Martin",
                        latitude: 39.33333, longitude: -76.41667},
                      %Station{id: "KDOV", state: "DE", name: "Dover Air Force Base",
                        latitude: 39.13333, longitude: -75.46667}]

    assert(get_key_matching_stations(station_list(), [latitude: 39, longitude: -76])
      == expected_result)
  end

  test "Get correct latitude matching stations from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                        latitude: 51.76667, longitude: -114.68333},
                      %Station{id: "CWDZ", state: "AB", name: "Drumheller East",
                        latitude: 51.44504, longitude: -112.69654}]

    assert(get_key_matching_stations(station_list(), [latitude: 51])
      == expected_result)
  end

  test "Get correct longitude matching stations from station list" do
    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                        latitude: 51.76667, longitude: -114.68333},
                      %Station{id: "CWDZ", state: "AB", name: "Drumheller East",
                        latitude: 51.44504, longitude: -112.69654},
                      %Station{id: "KMSO", state: "MT", name: "Missoula, Missoula International Airport",
                        latitude: 46.92083, longitude: -114.0925}]

    assert(get_key_matching_stations(station_list(), [longitude: -113.69])
      == expected_result)
  end
end
