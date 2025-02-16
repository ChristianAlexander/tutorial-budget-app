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
    query = from(b in Budget)

    Enum.reduce(criteria, query, fn
      {:user, user}, query ->
        from b in query, where: b.creator_id == ^user.id

      {:preload, bindings}, query ->
        preload(query, ^bindings)

      _, query ->
        query
    end)
    |> Repo.all()
  end

  def get_budget(id), do: Repo.get(Budget, id)

  def change_budget(budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end
end
