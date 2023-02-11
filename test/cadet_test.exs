defmodule CadetTest do
  use ExUnit.Case
  doctest Cadet

  test "greets the world" do
    assert Cadet.hello() == :world
  end
end
