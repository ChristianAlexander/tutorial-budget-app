defmodule Budgie.Tracking.BudgetPeriodTest do
  use Budgie.DataCase

  alias Budgie.Tracking.BudgetPeriod

  describe "changeset/2" do
    test "fails when start date is after the beginning of the month" do
      attrs = params_with_assocs(:budget_period, start_date: ~D[2025-01-05])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?

      assert %{start_date: ["must be the beginning of a month"]} = errors_on(changeset)
    end

    test "fails when end date is before the end of the month" do
      attrs = params_with_assocs(:budget_period, end_date: ~D[2025-01-15])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?

      assert %{end_date: ["must be the end of a month"]} = errors_on(changeset)
    end

    test "fails when both start and end date are incorrect" do
      attrs =
        params_with_assocs(:budget_period, start_date: ~D[2025-01-05], end_date: ~D[2025-01-15])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?

      assert %{
               start_date: ["must be the beginning of a month"],
               end_date: ["must be the end of a month"]
             } = errors_on(changeset)
    end

    test "valid when start and end dates are correct" do
      attrs = params_with_assocs(:budget_period)

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      assert changeset.valid?
    end
  end
end
