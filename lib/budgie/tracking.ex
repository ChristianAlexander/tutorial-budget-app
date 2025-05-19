defmodule Budgie.Tracking do
  import Ecto.Query, warn: false

  alias Budgie.Repo
  alias Budgie.Tracking.Budget

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

  defp budget_query(criteria) do
    query = from(b in Budget)

    Enum.reduce(criteria, query, fn
      {:user, user}, query ->
        from b in query, where: b.creator_id == ^user.id

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      _, query ->
        query
    end)
  end

  def change_budget(budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end

  alias Budgie.Tracking.BudgetTransaction

  def create_transaction(attrs \\ %{}) do
    %BudgetTransaction{}
    |> BudgetTransaction.changeset(attrs)
    |> Repo.insert()
  end

  def update_transaction(%BudgetTransaction{} = transaction, attrs) do
    transaction
    |> BudgetTransaction.changeset(attrs)
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

  def change_transaction(budget_transaction, attrs \\ %{}) do
    BudgetTransaction.changeset(budget_transaction, attrs)
  end

  def summarize_budget_transactions(%Budget{id: budget_id}),
    do: summarize_budget_transactions(budget_id)

  def summarize_budget_transactions(budget_id) do
    query =
      from t in transaction_query(budget: budget_id, order_by: nil),
        select: [t.type, sum(t.amount)],
        group_by: t.type

    query
    |> Repo.all()
    |> Enum.reduce(%{}, fn [type, amount], summary ->
      Map.put(summary, type, amount)
    end)
  end
end
