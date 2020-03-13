defmodule SatTest do
  use ExUnit.Case
  doctest Sat

  test "greets the world" do
    assert Sat.hello() == :world
  end
end
