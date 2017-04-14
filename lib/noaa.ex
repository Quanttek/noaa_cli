defmodule Noaa do
  alias Noaa.Weather
  alias Noaa.Station

  require Logger

  def decide_output([station = %Station{}]) do
    Logger.info "Only one station matched. Getting weather..."
    weather = Weather.get_struct(station)
    [station, weather]
  end

  def decide_output([]) do
    Logger.error "Could not find any stations matching your criteria!"
    System.halt(2)
  end

  def decide_output(station_list) do
    station_list
  end
end
