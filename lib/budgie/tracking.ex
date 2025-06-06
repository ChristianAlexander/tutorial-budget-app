defmodule Budgie.Tracking do
  import Ecto.Query, warn: false

  alias Budgie.Repo
  alias Budgie.Tracking.Budget
  alias Budgie.Tracking.BudgetJoinLink
  alias Budgie.Tracking.BudgetPeriod

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  def list_budgets, do: list_budgets([])

  def list_budgets(criteria) when is_list(criteria) do
    Repo.all(budget_query(criteria))
  end

  def get_budget(id, criteria \\ []) do
    Repo.get(budget_query(criteria), id)
  end

  def get_budget_by_join_code(code, criteria \\ []) do
    query = budget_query([{:join_link_code, code} | criteria])

    Repo.one(query)
  end

  defp budget_query(criteria) do
    query = from(b in Budget)

    Enum.reduce(criteria, query, fn
      {:user, user}, query ->
        from b in query, where: b.creator_id == ^user.id

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      {:join_link_code, code}, query ->
        from b in query,
          join: link in assoc(b, :join_link),
          where: link.code == ^code

      _, query ->
        query
    end)
  end

  def change_budget(budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end

  alias Budgie.Tracking.BudgetTransaction

  def create_transaction(%Budget{} = budget, attrs \\ %{}) do
    %BudgetTransaction{}
    |> BudgetTransaction.changeset(attrs, budget)
    |> Repo.insert()
  end

  def update_transaction(
        %BudgetTransaction{
          budget: %Budget{} = budget
        } = transaction,
        attrs
      ),
      do: update_transaction(budget, transaction, attrs)

  def update_transaction(
        %Budget{} = budget,
        %BudgetTransaction{} = transaction,
        attrs
      ) do
    transaction
    |> BudgetTransaction.changeset(attrs, budget)
    |> Repo.update()
  end

  def delete_transaction(%BudgetTransaction{} = transaction) do
    Repo.delete(transaction)
  end

  def list_transactions(budget_or_budget_id, criteria \\ [])

  def list_transactions(%Budget{id: budget_id}, criteria),
    do: list_transactions(budget_id, criteria)

  def list_transactions(budget_id, criteria) do
    transaction_query([{:budget, budget_id} | criteria])
    |> Repo.all()
  end

  defp transaction_query(criteria) do
    # Base query has a default sort order by effective date
    query = from(t in BudgetTransaction, order_by: [asc: :effective_date])

    Enum.reduce(criteria, query, fn
      {:budget, budget_id}, query ->
        from t in query, where: t.budget_id == ^budget_id

      {:order_by, binding}, query ->
        # Remove any existing ordering if sort is specified
        from t in exclude(query, :order_by), order_by: ^binding

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      {:between, {start_date, end_date}}, query ->
        where(query, [t], fragment("? BETWEEN ? AND ?", t.effective_date, ^start_date, ^end_date))

      _, query ->
        query
    end)
  end

  def change_transaction(
        %BudgetTransaction{
          budget: %Budget{} = budget
        } = transaction,
        attrs
      )
      when is_map(attrs) do
    BudgetTransaction.changeset(transaction, attrs, budget)
  end

  def summarize_budget_transactions(%Budget{id: budget_id}),
    do: summarize_budget_transactions(budget_id)

  def summarize_budget_transactions(budget_id) do
    query =
      from t in transaction_query(budget: budget_id, order_by: nil),
        join: p in BudgetPeriod,
        on:
          t.budget_id == p.budget_id and
            fragment("? BETWEEN ? AND ?", t.effective_date, p.start_date, p.end_date),
        select: [p.id, t.type, sum(t.amount)],
        group_by: fragment("GROUPING SETS ((?, ?), ?)", p.id, t.type, t.type)

    query
    |> Repo.all()
    |> Enum.reduce(
      Map.new(),
      fn
        [nil, type, amount], summary ->
          Map.update(summary, :total, %{type => amount}, fn existing ->
            Map.put(existing, type, amount)
          end)

        [period_id, type, amount], summary ->
          Map.update(summary, period_id, %{type => amount}, fn existing ->
            Map.put(existing, type, amount)
          end)
      end
    )
  end

  def get_budget_period(id, criteria \\ []) do
    Repo.get(budget_period_query(criteria), id)
  end

  def period_for_transaction(
        %BudgetTransaction{budget_id: budget_id, effective_date: effective_date},
        criteria \\ []
      ) do
    Keyword.merge(criteria, budget_id: budget_id, during: effective_date)
    |> budget_period_query()
    |> Repo.one()
  end

  defp budget_period_query(criteria) do
    query = from(p in BudgetPeriod)

    Enum.reduce(criteria, query, fn
      {:user, user}, query ->
        from p in query,
          join: b in assoc(p, :budget),
          where: b.creator_id == ^user.id

      {:budget_id, budget_id}, query ->
        from p in query, where: p.budget_id == ^budget_id

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      {:during, date}, query ->
        from p in query,
          where: fragment("? BETWEEN ? AND ?", ^date, p.start_date, p.end_date)

      _, query ->
        query
    end)
  end

  def ensure_join_link(%Budget{} = budget) do
    %BudgetJoinLink{}
    |> BudgetJoinLink.changeset(%{budget_id: budget.id})
    |> Repo.insert(
      on_conflict: {:replace, [:updated_at]},
      conflict_target: :budget_id,
      returning: true
    )
  end
end
