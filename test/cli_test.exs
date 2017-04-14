defmodule CliTest do
  use ExUnit.Case
  #doctest Noaa

  alias Noaa.Station
  import Noaa.CLI, only: [parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert(parse_args(["-h",     "anything"]) == :help)
    assert(parse_args(["--help", "anything"]) == :help)
  end

  test "correct %Station{} is returned when only switches are supplied by the user" do
    input1 = ["-i", "ABC", "--state", "AB", "-n", "ABDEFG"]
    input2 = ["-s", "AB", "--latitude", "75", "-g", "-100"]

    expected_result1 = %Station{id: "ABC", state: "AB", name: "ABDEFG",
                                latitude: 0.0, longitude: 0.0}
    expected_result2 = %Station{id: "", state: "AB", name: "",
                                latitude: 75, longitude: -100}

    assert(parse_args(input1) == expected_result1)
    assert(parse_args(input2) == expected_result2)
  end

  test "correct %Station{} is returned when both switched args and switch-less args are provided" do
    input1 = ["ABC", "--state", "AB", "-n", "ABDEFG"]
    input2 = ["-s", "AB", "--latitude", "75", "-g", "-100", "ABCDEFGH"]

    expected_result1 = %Station{id: "ABC", state: "AB", name: "ABDEFG",
                                latitude: 0.0, longitude: 0.0}
    expected_result2 = %Station{id: "", state: "AB", name: "ABCDEFGH",
                                latitude: 75, longitude: -100}

    assert(parse_args(input1) == expected_result1)
    assert(parse_args(input2) == expected_result2)
  end

end
