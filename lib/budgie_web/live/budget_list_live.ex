defmodule BudgieWeb.BudgetListLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking

  def mount(_params, _session, socket) do
    budgets =
      Tracking.list_budgets()
      |> Budgie.Repo.preload(:creator)

    socket = assign(socket, budgets: budgets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.table id="budgets" rows={@budgets}>
      <:col :let={budget} label="Name">{budget.name}</:col>
      <:col :let={budget} label="Description">{budget.description}</:col>
      <:col :let={budget} label="Start Date">{budget.start_date}</:col>
      <:col :let={budget} label="End Date">{budget.end_date}</:col>
      <:col :let={budget} label="Creator Name">{budget.creator.name}</:col>
    </.table>
    """
  end
end
