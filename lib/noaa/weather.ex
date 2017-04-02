defmodule NOAA.Weather do
  alias NOAA.Station
  alias NOAA.XMLParser

  defstruct [last_updated: "", weather: "", temp: 0.0, humidity: 0.0,
             wind: "", msl_pressure: 0.0]

  def get_struct(%Station{id: id}) do
    {:ok, weather_html} = NOAA.WebHandler.fetch(id)
    XMLParser.parse_station(weather_html)
  end
end
