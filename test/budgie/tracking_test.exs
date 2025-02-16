defmodule Budgie.TrackingTest do
  use Budgie.DataCase

  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "create_budget/2 with valid data creates budget" do
      user = Budgie.AccountsFixtures.user_fixture()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-31],
        creator_id: user.id
      }

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(valid_attrs)
      assert budget.name == "some name"
      assert budget.description == "some description"
      assert budget.start_date == ~D[2025-01-01]
      assert budget.end_date == ~D[2025-01-31]
      assert budget.creator_id == user.id
    end
  end

  test "create_budget/2 requires name" do
    user = Budgie.AccountsFixtures.user_fixture()

    attrs_without_name = %{
      description: "some description",
      start_date: ~D[2025-01-01],
      end_date: ~D[2025-01-31],
      creator_id: user.id
    }

    assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs_without_name)

    assert changeset.valid? == false
    assert Keyword.keys(changeset.errors) == [:name]
  end

  test "create_budget/2 requires valid dates" do
    user = Budgie.AccountsFixtures.user_fixture()

    attrs_end_before_start = %{
      name: "some name",
      description: "some description",
      start_date: ~D[2025-12-31],
      end_date: ~D[2025-01-01],
      creator_id: user.id
    }

    assert {:error, %Ecto.Changeset{} = changeset} =
             Tracking.create_budget(attrs_end_before_start)

    assert changeset.valid? == false
  end
end
