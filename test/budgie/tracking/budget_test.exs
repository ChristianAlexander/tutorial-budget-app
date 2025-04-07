defmodule Budgie.Tracking.BudgetTest do
  use Budgie.DataCase

  alias Budgie.Tracking.Budget

  describe "months_between/3" do
    test "provides a single month when given a single month range" do
      start_date = ~D[2025-01-01]
      end_date = ~D[2025-01-31]

      result = Budget.months_between(start_date, end_date)

      assert result == [%{start_date: start_date, end_date: end_date}]
    end

    test "provides three months when given a quarter range" do
      start_date = ~D[2025-01-01]
      end_date = ~D[2025-03-31]

      result = Budget.months_between(start_date, end_date)

      assert result == [
               %{start_date: ~D[2025-01-01], end_date: ~D[2025-01-31]},
               %{start_date: ~D[2025-02-01], end_date: ~D[2025-02-28]},
               %{start_date: ~D[2025-03-01], end_date: ~D[2025-03-31]}
             ]
    end
  end
end
