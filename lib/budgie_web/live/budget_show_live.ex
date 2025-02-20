defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking

  def mount(%{"budget_id" => id}, _session, socket) do
    budget =
      Tracking.get_budget(id)
      |> Budgie.Repo.preload(:creator)

    if budget do
      {:ok, assign(socket, budget: budget)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    {@budget.name} by {@budget.creator.name}
    """
  end
end
