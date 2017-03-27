defmodule NOAA.CLI do
  alias NOAA.Station

  def main(argv) do
    argv
    |> parse_args
  end

  #Users should be able to pass the following args: state, name, abbreviation, coordinates
  #state -> list
  #name, abbreviation -> weather
  #coordinates -> weather for closest location
  #standard: noaa [abbrv | name]
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean,
                                                id: :string,
                                                state: :string,
                                                name: :string,
                                                latitude: :float,
                                                longitude: :float,
                                                url: :string],
                                     aliases:  [h: :help,
                                                s: :state,
                                                n: :name,
                                                lat: :latitude,
                                                long: :longitutde,
                                                u: :url])

    case parse do
      {[help: true], _, _}
        -> :help
      {list, [], _}
        -> Station.parse_keywords(list, %Station{})
      {list, id_or_name, _}
        -> if String.length(id_or_name) > 4,
            do:   Station.parse_keywords(list, %Station{name: id_or_name}),
            else: Station.parse_keywords(list, %Station{id: id_or_name})
       _
        -> :help
    end
  end
end
