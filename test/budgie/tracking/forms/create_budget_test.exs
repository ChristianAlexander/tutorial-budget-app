defmodule Budgie.Tracking.Forms.CreateBudgetTest do
  use Budgie.DataCase, async: true

  alias Budgie.Tracking.Forms.CreateBudget

  describe "changeset/2" do
    test "validates monthly funding amount" do
      changeset =
        CreateBudget.changeset(%CreateBudget{}, %{
          period_funding_amount: -1,
          budget: params_with_assocs(:budget)
        })

      assert changeset.valid? == false

      errors = errors_on(changeset)

      assert %{period_funding_amount: ["must be greater than or equal to 0"]} = errors
    end

    test "validates budget name presence" do
      budget_attrs =
        params_with_assocs(:budget)
        |> Map.delete(:name)

      changeset =
        CreateBudget.changeset(%CreateBudget{}, %{
          period_funding_amount: 1000,
          budget: budget_attrs
        })

      assert changeset.valid? == false
      errors = errors_on(changeset)

      assert %{budget: %{name: ["can't be blank"]}} = errors
    end

    test "returns valid with correct attributes" do
      attrs = %{
        period_funding_amount: 5000,
        budget: params_with_assocs(:budget)
      }

      changeset = CreateBudget.changeset(%CreateBudget{}, attrs)

      assert changeset.valid? == true
    end

    test "validates budget date requirements" do
      budget_attrs =
        params_with_assocs(:budget)
        |> Map.merge(%{
          start_date: ~D[2025-12-01],
          end_date: ~D[2025-01-31]
        })

      changeset =
        CreateBudget.changeset(%CreateBudget{}, %{
          period_funding_amount: 1000,
          budget: budget_attrs
        })

      assert changeset.valid? == false
      errors = errors_on(changeset)

      assert %{budget: %{end_date: ["must end after start date"]}} = errors
    end
  end

  describe "submit/2" do
    test "creates funded budget when funding amount is provided" do
      user = insert(:user)

      form = Phoenix.Component.to_form(CreateBudget.new())

      attrs = %{
        "period_funding_amount" => 123,
        "budget" => string_params_for(:budget, creator_id: user.id)
      }

      result = CreateBudget.submit(form, attrs)

      assert {:ok, %{budget: budget, fund_budget: transactions}} = result
      assert budget.creator_id == user.id
      assert Enum.count(budget.periods) == Enum.count(transactions)

      assert Enum.all?(transactions, fn tx ->
               tx.type == :funding and
                 tx.amount == Decimal.new("123") and
                 tx.description == "Recurring funding"
             end)
    end

    test "returns invalid changeset when period funding amount is invalid" do
      user = insert(:user)

      form = Phoenix.Component.to_form(CreateBudget.new())

      attrs = %{
        "period_funding_amount" => -100,
        "budget" => string_params_for(:budget, creator_id: user.id)
      }

      result = CreateBudget.submit(form, attrs)

      assert {:error, changeset} = result
      assert changeset.valid? == false

      assert %{period_funding_amount: ["must be greater than or equal to 0"]} =
               errors_on(changeset)
    end

    test "returns empty transaction list when funding amount is nil" do
      user = insert(:user)

      form = Phoenix.Component.to_form(CreateBudget.new())

      attrs = %{
        "period_funding_amount" => nil,
        "budget" => string_params_for(:budget, creator_id: user.id)
      }

      result = CreateBudget.submit(form, attrs)

      assert {:ok, %{budget: budget, fund_budget: transactions}} = result
      assert budget.creator_id == user.id
      assert [] = transactions
    end

    test "creates periods along with the budget" do
      user = insert(:user)

      form = Phoenix.Component.to_form(CreateBudget.new())

      budget_attrs =
        string_params_for(:budget)
        |> Map.merge(%{
          "start_date" => "2025-01-01",
          "end_date" => "2025-02-28",
          "creator_id" => user.id
        })

      attrs = %{
        "period_funding_amount" => nil,
        "budget" => budget_attrs
      }

      result = CreateBudget.submit(form, attrs)

      assert {:ok, %{budget: budget, fund_budget: _transactions}} = result
      assert Enum.count(budget.periods) == 2

      [january_period, february_period] = budget.periods
      assert january_period.start_date == ~D[2025-01-01]
      assert january_period.end_date == ~D[2025-01-31]
      assert february_period.start_date == ~D[2025-02-01]
      assert february_period.end_date == ~D[2025-02-28]
    end

    test "creates budget with all correct attributes" do
      user = insert(:user)

      form = Phoenix.Component.to_form(CreateBudget.new())

      budget_attrs =
        string_params_for(:budget)
        |> Map.merge(%{
          "name" => "Test Budget",
          "description" => "Test Description",
          "start_date" => "2025-03-01",
          "end_date" => "2025-03-31",
          "creator_id" => user.id
        })

      attrs = %{
        "period_funding_amount" => nil,
        "budget" => budget_attrs
      }

      result = CreateBudget.submit(form, attrs)

      assert {:ok, %{budget: budget, fund_budget: _transactions}} = result
      assert budget.name == "Test Budget"
      assert budget.description == "Test Description"
      assert budget.start_date == ~D[2025-03-01]
      assert budget.end_date == ~D[2025-03-31]
      assert budget.creator_id == user.id
    end
  end
end
