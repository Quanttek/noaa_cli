defmodule XMLParserTest do
  use ExUnit.Case
  #doctest Noaa

  alias NOAA.Station
  import NOAA.XMLParser, only: [parse_station_list: 1]

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
end
