defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: [:creator, :periods]
      )

    if budget do
      summary = Tracking.summarize_budget_transactions(budget)

      {:ok,
       assign(socket,
         budget: budget,
         summary: summary
       )}
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

  defp default_transaction(budget) do
    %BudgetTransaction{
      effective_date: Date.utc_today(),
      budget: budget
    }
  end
end
