defmodule BudgieWeb.CreateTransactionDialog do
  use BudgieWeb, :live_component

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  @impl true
  def update(assigns, socket) do
    changeset =
      Tracking.change_transaction(default_transaction(), %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      default_transaction()
      |> Tracking.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    budget = socket.assigns.budget

    transaction_params =
      Map.put(transaction_params, "budget_id", budget.id)

    case Tracking.create_transaction(transaction_params) do
      {:ok, _transaction} ->
        socket =
          socket
          |> put_flash(:info, "Transaction created")
          |> push_navigate(to: ~p"/budgets/#{budget}", replace: true)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset))
  end

  defp default_transaction do
    %BudgetTransaction{
      effective_date: Date.utc_today()
    }
  end
end
