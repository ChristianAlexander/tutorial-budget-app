defmodule BudgieWeb.CreateBudgetDialog do
  use BudgieWeb, :live_component

  alias Budgie.Tracking.Budget
  alias Budgie.Tracking.Forms.CreateBudget

  @impl true
  def update(assigns, socket) do
    changeset = CreateBudget.new()

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"create_budget" => params}, socket) do
    changeset =
      CreateBudget.new()
      |> CreateBudget.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"create_budget" => params}, socket) do
    params = put_in(params, ["budget", "creator_id"], socket.assigns.current_user.id)

    with {:ok, %{budget: %Budget{} = budget}} <-
           CreateBudget.submit(socket.assigns.form, params) do
      socket =
        socket
        |> put_flash(:info, "Budget created")
        |> push_navigate(to: ~p"/budgets/#{budget}", replace: true)

      {:noreply, socket}
    else
      {:error, changeset} -> {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
