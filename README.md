# Noaa CLI Weather

**Tries to display the weather for a stations matching the user's input.
If multiple stations match a list of those is provided.**

## Usage

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

## Examples

```
$ escript noaa KCGS
KCGS | College Park Airport | MD | 38.9806 N | 76.9223 W
☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️☁️
  Updated at | 8:41 am EDT
     Weather | Overcast
  Temp. (°F) | 55.0
Humidity (%) | 72
        Wind | North at 0.0 MPH
```

```
$ escript noaa -s MD -t 38 -g -77
#    | Name                                                        | State | Latitude   | Longitude
-----+-------------------------------------------------------------+-------+------------+-----------
KADW | Camp Springs / Andrews Air Force Base                       | MD    | 38.81667 N | 76.85 W
KESN | Easton / Newman Field                                       | MD    | 38.8 N     | 76.06667 W
KNAK | Annapolis, United States Naval Academy                      | MD    | 38.99125 N | 76.48907 W
KNHK | Patuxent River, Naval Air Station                           | MD    | 38.27861 N | 76.41389 W
KNUI | St. Inigoes, Webster Field, Naval Electronic Systems Engine | MD    | 38.14889 N | 76.42 W
K2W6 | St Marys County Airport                                     | MD    | 38.3154 N  | 76.5501 W
KCGE | Cambridge-Dorchester Airport                                | MD    | 38.5393 N  | 76.0304 W
KCGS | College Park Airport                                        | MD    | 38.9806 N  | 76.9223 W
KW29 | Bay Bridge Field                                            | MD    | 38.9767 N  | 76.33 W
```

## Installation

1. Install [Elixir](http://elixir-lang.org/install.html)
2. Download or `git clone` the repository
3. Compile with `mix escript.build`
4. Run either with `./noaa` (Linux) or `escript noaa` (Windows)
