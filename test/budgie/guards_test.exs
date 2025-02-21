defmodule Budgie.GuardsTest do
  use ExUnit.Case, async: true

  import Budgie.Guards

  describe "is_uuid" do
    test "True when the string is a UUID" do
      assert is_uuid("f64cd889-664a-410d-996a-2edcf1e26d4a")
    end

    test "False when the string is not a UUID" do
      refute is_uuid("christian")
    end
  end
end
