defmodule BudgieWeb.TransactionDialog do
  use BudgieWeb, :live_component

  alias Budgie.Tracking

  @impl true
  def update(assigns, socket) do
    changeset =
      Tracking.change_transaction(assigns.transaction, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Tracking.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :new_transaction, transaction_params) do
    budget = socket.assigns.budget

    transaction_params =
      Map.put(transaction_params, "budget_id", budget.id)

    case Tracking.create_transaction(budget, transaction_params) do
      {:ok, transaction} ->
        socket =
          socket
          |> put_flash(:info, "Transaction created")
          |> push_navigate(
            to: destination_on_success(transaction),
            replace: true
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp save_transaction(socket, :edit_transaction, transaction_params) do
    budget = socket.assigns.budget

    transaction_params =
      Map.put(transaction_params, "budget_id", budget.id)

    case Tracking.update_transaction(socket.assigns.transaction, transaction_params) do
      {:ok, transaction} ->
        socket =
          socket
          |> put_flash(:info, "Transaction updated")
          |> push_navigate(
            to: destination_on_success(transaction),
            replace: true
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp destination_on_success(created_transaction) do
    period = Tracking.period_for_transaction(created_transaction)

    ~p"/budgets/#{period.budget_id}/periods/#{period.id}"
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset, as: "transaction"))
  end
end
