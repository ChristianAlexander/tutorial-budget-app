defmodule BudgieWeb.PeriodShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction
  alias Budgie.Repo

  def mount(%{"id" => id, "budget_id" => budget_id} = params, _session, socket)
      when is_uuid(id) and is_uuid(budget_id) do
    current_user = socket.assigns.current_user

    case Tracking.get_budget_period(
           id,
           user: current_user,
           budget_id: budget_id
         )
         |> Repo.preload(:budget) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Not found")
          |> redirect(to: ~p"/budgets")

        {:ok, socket}

      period ->
        transactions =
          Tracking.list_transactions(period.budget_id,
            between: {period.start_date, period.end_date}
          )

        {:ok,
         assign(socket,
           period: period,
           transactions: transactions
         )
         |> apply_action(params)}
    end
  end

  def mount(_parms, _session, socket) do
    socket =
      socket
      |> put_flash(:error, "Not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  def apply_action(%{assigns: %{live_action: :edit_transaction}} = socket, %{
        "transaction_id" => transaction_id
      }) do
    transaction =
      Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      assign(socket, transaction: Map.put(transaction, :budget, socket.assigns.period.budget))
    else
      socket
      |> put_flash(:error, "Transaction not found")
      |> redirect(
        to: ~p"/budgets/#{socket.assigns.period.budget}/periods/#{socket.assigns.period}"
      )
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
            |> push_navigate(
              to: ~p"/budgets/#{socket.assigns.period.budget}/periods/#{socket.assigns.period}",
              replace: true
            )

          {:noreply, socket}

        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Failed to delete transaction")}
      end
    else
      {:noreply, put_flash(socket, :error, "Transaction not found")}
    end
  end

  defp default_transaction(assigns) do
    today = Date.utc_today()

    effective_date =
      cond do
        Date.before?(today, assigns.period.start_date) ->
          assigns.period.start_date

        Date.after?(today, assigns.period.end_date) ->
          assigns.period.end_date

        true ->
          today
      end

    %BudgetTransaction{
      effective_date: effective_date,
      budget: assigns.period.budget
    }
  end
end
