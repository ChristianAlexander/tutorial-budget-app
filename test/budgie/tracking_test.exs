defmodule Budgie.TrackingTest do
  use Budgie.DataCase

  import Budgie.TrackingFixtures

  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "create_budget/2 with valid data creates budget" do
      user = Budgie.AccountsFixtures.user_fixture()

      attrs = valid_budget_attributes(%{creator_id: user.id})

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(attrs)
      assert budget.name == attrs.name
      assert budget.description == attrs.description
      assert budget.start_date == attrs.start_date
      assert budget.end_date == attrs.end_date
      assert budget.creator_id == user.id
    end

    test "create_budget/2 requires name" do
      attrs =
        valid_budget_attributes()
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/2 requires valid dates" do
      attrs =
        valid_budget_attributes()
        |> Map.merge(%{
          start_date: ~D[2025-12-31],
          end_date: ~D[2025-01-01]
        })

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{end_date: ["must end after start date"]} = errors_on(changeset)
    end
  end
end
