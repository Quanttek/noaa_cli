defmodule Noaa.WebHandler do
  require Logger

  @user_agent [ {"User-agent", "Elixir-based weather client"}]
  @noaa_url Application.get_env(:noaa, :noaa_url)

  def fetch(id) do
    Logger.info("Fetching data for #{id} station")
    xml_url(id)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def fetch_list do
    Logger.info("Fetching station list")
    xml_url()
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def decode_response({:ok, body}) do
    body
  end

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "Message", 0)
    IO.puts "Error fetching from Noaa servers: #{message}"
    System.halt(2)
  end

  def xml_url() do
    "#{@noaa_url}/index.xml"
  end
  def xml_url("index") do #TODO: Delete?
    "#{@noaa_url}/index.xml"
  end
  def xml_url(id) when is_bitstring(id) do
    id = String.upcase(id)
    "#{@noaa_url}/#{id}.xml"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Logger.info("Successful response")
    Logger.debug(fn -> inspect(body) end)
    {:ok, body}
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: status, body: body}}) do
    Logger.error("Error #{status} returned")
    {:error, body}
  end
end
