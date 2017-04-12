defmodule NOAA.Weather do
  alias NOAA.Station
  alias NOAA.XMLParser
  alias NOAA.Weather

  defstruct [last_updated: "", weather: "", temp: "", humidity: "",
             wind: "", msl_pressure: ""]

  def get_struct(%Station{id: id}) do
    {:ok, weather_html} = NOAA.WebHandler.fetch(id)
    XMLParser.parse_station(weather_html)
  end

  def get_emoji(%Weather{weather: weather}) do #This is so ugly
    cond do
      Regex.match?(~r{Overcast}, weather)
        -> "☁️" #Emoji: Cloud
      Regex.match?(~r{(Fair|Clear)}, weather)
        -> "☀" #Emoji: Sun
      Regex.match?(~r{A Few Clouds}, weather)
        -> "🌤" #Emoji: Sun Behind Small Cloud
      Regex.match?(~r{Partly Cloudy}, weather)
        -> "⛅" #Emoji: Sun Behind Cloud
      Regex.match?(~r{Mostly Cloudy}, weather)
        -> "🌥️" #Emoji: Sun Behind Large Cloud
      Regex.match?(~r{(?=.*?(Thunderstorm))(?=.*?(Rain|Showers))}, weather)
        -> "⛈" #Emoji: Cloud with Rain and Lightning
      Regex.match?(~r{(?=.*?(Thunderstorm))(?=.*?(Hail|Pellets))}, weather)
        -> "⛈❄" #Emoji: Cloud with Rain and Lightning + Snowflake
      Regex.match?(~r{Thunderstorm}, weather)
        -> "🌩" #Emoji: Cloud with Lightning
      Regex.match?(~r{(Fog|Mist)}, weather)
        -> "🌫️" #Emoji: Fog
      Regex.match?(~r{(?=.*?(Rain|Drizzle))(?=.*?(Snow))}, weather)
        -> "🌧🌨" #Emojis: Cloud With Rain + Cloud With Snow
      Regex.match?(~r{((Freezing (Rain|Drizzle)|Pellets)|Ice Crystals|Hail)}, weather)
        -> "💧❄" #Emojis: Droplet + Snowflake
      Regex.match?(~r{Snow}, weather)
        -> "🌨" #Emoji: Cloud with Snow
      Regex.match?(~r{(Rain|Shower|Drizzle)}, weather)
        -> "🌧" #Emoji: Cloud with Rain
      Regex.match?(~r{(Funnel Cloud|Tornado|Water Spout)}, weather)
        -> "🌪" #Emoji: Tornado
      Regex.match?(~r{(Windy|Breezy)}, weather)
        -> "💨" #Emoji: Dashing Away
      Regex.match?(~r{(Dust|Sand)}, weather)
        -> "💨" #Emoji: Dashing Away
      true -> "-"
    end
  end
end
