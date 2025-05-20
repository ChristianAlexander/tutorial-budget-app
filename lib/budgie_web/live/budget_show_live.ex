defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def mount(%{"budget_id" => id} = params, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: [:creator, :periods]
      )

    if budget do
      transactions =
        Tracking.list_transactions(budget)

      summary = Tracking.summarize_budget_transactions(budget)

      {:ok,
       assign(socket,
         budget: budget,
         transactions: transactions,
         summary: summary
       )
       |> apply_action(params)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  def mount(_invalid_id, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "Budget not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  def apply_action(%{assigns: %{live_action: :edit_transaction}} = socket, %{
        "transaction_id" => transaction_id
      }) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      assign(socket, transaction: transaction)
    else
      socket
      |> put_flash(:error, "Transaction not found")
      |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")
    end
  end

  def apply_action(socket, _), do: socket

  def handle_event("delete_transaction", %{"id" => transaction_id}, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      case Tracking.delete_transaction(transaction) do
        {:ok, _} ->
          socket =
            socket
            |> put_flash(:info, "Transaction deleted")
            |> push_navigate(to: ~p"/budgets/#{socket.assigns.budget.id}", replace: true)

          {:noreply, socket}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to delete transaction")}
      end
    else
      {:noreply, put_flash(socket, :error, "Transaction not found")}
    end
  end

  defp default_transaction(budget) do
    %BudgetTransaction{
      effective_date: Date.utc_today(),
      budget: budget
    }
  end
end
