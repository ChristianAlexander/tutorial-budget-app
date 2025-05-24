defmodule Budgie.TrackingTest do
  use Budgie.DataCase

  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "create_budget/1 with valid data creates budget" do
      attrs = params_with_assocs(:budget)

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(attrs)
      assert budget.name == attrs.name
      assert budget.description == attrs.description
      assert budget.start_date == attrs.start_date
      assert budget.end_date == attrs.end_date
      assert budget.creator_id == attrs.creator_id
    end

    test "create_budget/1 with valid data creates periods along with the budget" do
      user = insert(:user)

      valid_attrs = %{
        name: "some name",
        description: "some description",
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-02-28],
        creator_id: user.id
      }

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(valid_attrs)
      assert Enum.count(budget.periods) == 2

      [january_period, february_period] = budget.periods
      assert january_period.start_date == ~D[2025-01-01]
      assert january_period.end_date == ~D[2025-01-31]
      assert february_period.start_date == ~D[2025-02-01]
      assert february_period.end_date == ~D[2025-02-28]
    end

    test "create_budget/1 requires name" do
      attrs =
        params_with_assocs(:budget)
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_budget/1 requires valid dates" do
      attrs =
        params_with_assocs(:budget,
          start_date: ~D[2025-12-01],
          end_date: ~D[2025-01-31]
        )

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert %{end_date: ["must end after start date"]} = errors_on(changeset)
    end

    test "list_budgets/0 returns all budgets" do
      budgets = insert_pair(:budget)

      assert Tracking.list_budgets() == without_preloads(budgets)
    end

    test "list_budgets/1 scopes to the provided user" do
      [budget, _other_budget] = insert_pair(:budget)

      assert Tracking.list_budgets(user: budget.creator) == [without_preloads(budget)]
    end

    test "get_budget/1 returns the budget with given id" do
      budget = insert(:budget) |> without_preloads()

      assert Tracking.get_budget(budget.id) == budget
    end

    test "get_budget/1 returns nil when budget doesn't exist" do
      _unrelated_budget = insert(:budget)
      assert is_nil(Tracking.get_budget("10fe1ad8-6133-5d7d-b5c9-da29581bb923"))
    end
  end

  describe "budget transactions" do
    alias Budgie.Tracking.BudgetTransaction

    @invalid_attrs %{description: nil, effective_date: nil, amount: nil, creator_id: nil}

    test "list_transactions/1 returns all transactions in the budget, by id" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)
      _other_transactions = insert_pair(:budget_transaction)

      assert Tracking.list_transactions(budget.id) == without_preloads(transactions)
    end

    test "list_transactions/1 returns all transactions in the budget, by reference" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)
      _other_transactions = insert_pair(:budget_transaction)

      assert Tracking.list_transactions(budget) == without_preloads(transactions)
    end

    test "list_transactions/2 returns transactions with preloads" do
      budget = insert(:budget)

      transactions = insert_pair(:budget_transaction, budget: budget)

      assert Tracking.list_transactions(budget, preload: [budget: :creator]) == transactions
    end

    test "list_transactions/2 returns sorted transactions" do
      budget = insert(:budget)

      late_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-12-31])

      early_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-01])

      mid_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-06-15])

      expected_transactions =
        [
          late_transaction,
          mid_transaction,
          early_transaction
        ]
        |> without_preloads()

      assert Tracking.list_transactions(budget, order_by: [desc: :effective_date]) ==
               expected_transactions
    end

    test "list_transactions/2 filters transactions with between" do
      budget = insert(:budget)

      _before_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2024-12-31])

      start_month_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-01])

      mid_month_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-15])

      end_month_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-31])

      _after_transaction =
        insert(:budget_transaction, budget: budget, effective_date: ~D[2025-02-01])

      expected_transactions =
        [
          start_month_transaction,
          mid_month_transaction,
          end_month_transaction
        ]
        |> without_preloads()

      assert Tracking.list_transactions(budget, between: {~D[2025-01-01], ~D[2025-01-31]}) ==
               expected_transactions
    end

    test "create_transaction/1 with valid data creates a transaction" do
      budget = insert(:budget)

      valid_params = params_with_assocs(:budget_transaction, budget: budget)

      assert {:ok, %BudgetTransaction{} = transaction} =
               Tracking.create_transaction(budget, valid_params)

      assert transaction.type == valid_params.type
      assert transaction.description == valid_params.description
      assert transaction.effective_date == valid_params.effective_date
      assert transaction.amount == valid_params.amount
      assert transaction.budget_id == budget.id
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      budget = insert(:budget)
      assert {:error, %Ecto.Changeset{}} = Tracking.create_transaction(budget, @invalid_attrs)
    end

    test "change_transaction/1 with valid data returns a valid changeset" do
      budget = build(:budget)
      valid_params = params_with_assocs(:budget_transaction, budget: budget)

      assert %Ecto.Changeset{valid?: true} =
               Tracking.change_transaction(
                 %BudgetTransaction{budget: budget},
                 valid_params
               )
    end

    test "change_transaction/1 with invalid data returns an invalid changeset" do
      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(
                 %BudgetTransaction{
                   budget: build(:budget)
                 },
                 @invalid_attrs
               )
    end

    test "change_transaction/1 with negative amount returns an error" do
      budget = build(:budget)

      params =
        params_with_assocs(:budget_transaction, amount: Decimal.new("-1"), budget: budget)

      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(%BudgetTransaction{budget: budget}, params)
    end

    test "change_transaction/1 with HUGE amount returns an error" do
      budget = build(:budget)

      params =
        params_with_assocs(:budget_transaction, budget: budget, amount: Decimal.new("1000000000"))

      assert %Ecto.Changeset{valid?: false} =
               Tracking.change_transaction(%BudgetTransaction{budget: budget}, params)
    end

    test "summarize_budget_transactions/1 doesn't fail without transactions" do
      budget = insert(:budget)

      assert Tracking.summarize_budget_transactions(budget) == %{}
    end

    test "returns a summary with funding and spending, by period and with total" do
      budget = insert(:budget)

      january =
        insert(:budget_period,
          budget: budget,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        )

      february =
        insert(:budget_period,
          budget: budget,
          start_date: ~D[2025-02-01],
          end_date: ~D[2025-02-28]
        )

      _january_spending_transactions = [
        insert(:budget_transaction,
          budget: budget,
          type: :spending,
          effective_date: ~D[2025-01-15],
          amount: Decimal.new("2")
        ),
        insert(:budget_transaction,
          budget: budget,
          type: :spending,
          effective_date: ~D[2025-01-15],
          amount: Decimal.new("3")
        )
      ]

      _january_funding_transactions = [
        insert(:budget_transaction,
          budget: budget,
          type: :funding,
          effective_date: ~D[2025-01-15],
          amount: Decimal.new("5")
        ),
        insert(:budget_transaction,
          budget: budget,
          type: :funding,
          effective_date: ~D[2025-01-15],
          amount: Decimal.new("7")
        )
      ]

      _february_spending_transaction =
        insert(:budget_transaction,
          budget: budget,
          type: :spending,
          effective_date: ~D[2025-02-15],
          amount: Decimal.new("11")
        )

      _february_funding_transaction =
        insert(:budget_transaction,
          budget: budget,
          type: :funding,
          effective_date: ~D[2025-02-15],
          amount: Decimal.new("13")
        )

      result = Tracking.summarize_budget_transactions(budget.id)

      assert Map.get(result, :total) == %{
               spending: Decimal.new("16"),
               funding: Decimal.new("25")
             }

      assert Map.get(result, january.id) == %{
               spending: Decimal.new("5"),
               funding: Decimal.new("12")
             }

      assert Map.get(result, february.id) == %{
               spending: Decimal.new("11"),
               funding: Decimal.new("13")
             }
    end
  end

  describe "budget periods" do
    test "get_budget_period/1 returns nil when period does not exist" do
      fake_period_id = Ecto.UUID.generate()

      assert is_nil(Tracking.get_budget_period(fake_period_id))
    end

    test "get_budget_period/1 returns the period with given id" do
      period = insert(:budget_period)

      assert Tracking.get_budget_period(period.id) == without_preloads(period)
    end

    test "get_budget_period/2 returns the period if the user and budget matches" do
      period = insert(:budget_period)

      assert Tracking.get_budget_period(period.id,
               user: period.budget.creator,
               budget_id: period.budget_id
             ) ==
               without_preloads(period)
    end

    test "get_budget_period/2 returns nil when the user doesn't have access to the period's budget" do
      period = insert(:budget_period)
      user = insert(:user)

      assert is_nil(Tracking.get_budget_period(period.id, user: user))
    end

    test "get_budget_period/2 returns nil when the budget ID doesn't match the period's budget" do
      period = insert(:budget_period)
      budget = insert(:budget)

      assert is_nil(Tracking.get_budget_period(period.id, budget_id: budget.id))
    end

    test "get_budget_period/2 preloads when requested" do
      period = insert(:budget_period)

      budget = Tracking.get_budget(period.budget.id)
      result = Tracking.get_budget_period(period.id, preload: :budget)

      assert result.budget == budget
    end

    test "period_for_transaction/1 returns the period overlapping with the provided transaction" do
      budget = insert(:budget)

      _january =
        insert(:budget_period,
          budget: budget,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        )

      february =
        insert(:budget_period,
          budget: budget,
          start_date: ~D[2025-02-01],
          end_date: ~D[2025-02-28]
        )

      transaction = insert(:budget_transaction, budget: budget, effective_date: ~D[2025-02-05])

      assert Tracking.period_for_transaction(transaction) == without_preloads(february)
    end
  end
end
