defmodule XMLParserTest do
  use ExUnit.Case
  #doctest Noaa

  import Noaa.XMLParser, only: [parse_station_list: 1,
                                parse_station: 1]
  alias Noaa.Station
  alias Noaa.Weather

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
    xml_string = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<wx_station_index>\n        <credit>Noaa's National Weather Service</credit>\n        <credit_URL>http://weather.gov/</credit_URL>\n        <image>\n                <url>http://weather.gov/images/xml_logo.gif</url>\n                <title>Noaa's National Weather Service</title>\n                <link>http://weather.gov</link>\n        </image>\n        <suggested_pickup>08:00 EST</suggested_pickup>\n        <suggested_pickup_period>1140</suggested_pickup_period>\n\t<station>\n\t\t<station_id>CWAV</station_id>\n\t\t<state>AB</state>\n            \t<station_name>Sundre</station_name>\n\t\t<latitude>51.76667</latitude>\n\t\t<longitude>-114.68333</longitude>\n            \t<html_url>http://weather.noaa.gov/weather/current/CWAV.html</html_url>\n            \t<rss_url>http://weather.gov/xml/current_obs/CWAV.rss</rss_url>\n            \t<xml_url>http://weather.gov/xml/current_obs/CWAV.xml</xml_url>\n\t</station>\n\n</wx_station_index>\n"

    expected_result = [%Station{id: "CWAV", state: "AB", name: "Sundre",
                      latitude: 51.76667, longitude: -114.68333}]

    assert(parse_station_list(xml_string) == expected_result)
  end

  test "Get correct %Weather{} struct from weather html document" do
    xml_document = "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> \r\n<?xml-stylesheet href=\"latest_ob.xsl\" type=\"text/xsl\"?>\r\n<current_observation version=\"1.0\"\r\n\t xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\r\n\t xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n\t xsi:noNamespaceSchemaLocation=\"http://www.weather.gov/view/current_observation.xsd\">\r\n\t<credit>NOAA's National Weather Service</credit>\r\n\t<credit_URL>http://weather.gov/</credit_URL>\r\n\t<image>\r\n\t\t<url>http://weather.gov/images/xml_logo.gif</url>\r\n\t\t<title>NOAA's National Weather Service</title>\r\n\t\t<link>http://weather.gov</link>\r\n\t</image>\r\n\t<suggested_pickup>15 minutes after the hour</suggested_pickup>\r\n\t<suggested_pickup_period>60</suggested_pickup_period>\n\t<location>Denton Municipal Airport, TX</location>\n\t<station_id>KDTO</station_id>\n\t<latitude>33.20505</latitude>\n\t<longitude>-97.20061</longitude>\n\t<observation_time>Last Updated on Apr 14 2017, 2:53 pm CDT</observation_time>\r\n        <observation_time_rfc822>Fri, 14 Apr 2017 14:53:00 -0500</observation_time_rfc822>\n\t<weather>Partly Cloudy</weather>\n\t<temperature_string>78.0 F (25.6 C)</temperature_string>\r\n\t<temp_f>78.0</temp_f>\r\n\t<temp_c>25.6</temp_c>\n\t<relative_humidity>56</relative_humidity>\n\t<wind_string>from the South at 18.4 gusting to 23.0 MPH (16 gusting to 20 KT)</wind_string>\n\t<wind_dir>South</wind_dir>\n\t<wind_degrees>160</wind_degrees>\n\t<wind_mph>18.4</wind_mph>\n\t<wind_gust_mph>23.0</wind_gust_mph>\n\t<wind_kt>16</wind_kt>\n\t<wind_gust_kt>20</wind_gust_kt>\n\t<pressure_string>1016.9 mb</pressure_string>\n\t<pressure_mb>1016.9</pressure_mb>\n\t<pressure_in>30.05</pressure_in>\n\t<dewpoint_string>61.0 F (16.1 C)</dewpoint_string>\r\n\t<dewpoint_f>61.0</dewpoint_f>\r\n\t<dewpoint_c>16.1</dewpoint_c>\n\t<visibility_mi>10.00</visibility_mi>\n \t<icon_url_base>http://forecast.weather.gov/images/wtf/small/</icon_url_base>\n\t<two_day_history_url>http://www.weather.gov/data/obhistory/KDTO.html</two_day_history_url>\n\t<icon_url_name>sct.png</icon_url_name>\n\t<ob_url>http://www.weather.gov/data/METAR/KDTO.1.txt</ob_url>\n\t<disclaimer_url>http://weather.gov/disclaimer.html</disclaimer_url>\r\n\t<copyright_url>http://weather.gov/disclaimer.html</copyright_url>\r\n\t<privacy_policy_url>http://weather.gov/notice.html</privacy_policy_url>\r\n</current_observation>\n"

    expected_result = %Weather{last_updated: "2:53 pm CDT",
                               weather: "Partly Cloudy",
                               temp: "78.0", humidity: "56",
                               wind: "South at 18.4 MPH",
                               msl_pressure: "1016.9"}

    assert(parse_station(xml_document) == expected_result)
  end
end
