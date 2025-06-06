defmodule BudgieWeb.Budgets.CollaboratorsDialog do
  use BudgieWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end
end
