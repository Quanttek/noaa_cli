defmodule Noaa.CLI do
  import Noaa, only: [decide_output: 1]
  import Noaa.Station, only: [parse_keywords: 2]
  import Noaa.Format, only: [create_table: 1]

  alias Noaa.Station

  def main(argv) do
    argv
    |> parse_args()
    |> process()
  end

  #Users should be able to pass the following args: state, name, abbreviation, coordinates
  #state -> list
  #name, abbreviation -> weather
  #coordinates -> weather for closest location
  #standard: noaa [abbrv | name]
  #TODO: Add url: :string back
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean,
                                                id: :string,
                                                state: :string,
                                                name: :string,
                                                latitude: :float,
                                                longitude: :float],
                                     aliases:  [h: :help,
                                                i: :id,
                                                s: :state,
                                                n: :name,
                                                t: :latitude,
                                                g: :longitude])

    case parse do
      {[help: true], _, _}
        -> :help
      {[], [], []}
        -> :help
      {list, [], _}
        -> parse_keywords(list, %Station{})
      {list, [id_or_name], _}
        -> if String.length(id_or_name) > 4,
            do:   parse_keywords(list, %Station{name: id_or_name}),
            else: parse_keywords(list, %Station{id: id_or_name})
       _
        -> :help
    end
  end

  def process(:help) do
    IO.puts """
    NOAA CLI Weather

    Tries to display the weather for a stations matching the user's input.
    If multiple stations match a list of those is provided.

    Usage:
      noaa [(id | name) | options]
      noaa (id | name) options

    Options:
      -h  --help      Displays this help text
      -i  --id        Takes a station's id
      -s  --state     Either takes an ANSI abbreviation or the name of an U.S. or Canadian state
      -n  --name      Takes a complete name of a station
      -t  --latitude  Takes a signed number with values < 0 for south and values > 0 for north
      -g  --longitude Takes a signed number with values < 0 for west and values > 0 for east

    When providing latitude or longitude values (or both) a station only matches
    if it is less than one degree away
    """
  end

  def process(struct = %Station{}) do
    struct
    |> Station.get_matching()
    |> decide_output()
    |> create_table()
    |> IO.puts()
  end
end
