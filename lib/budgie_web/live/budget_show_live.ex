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
      ending_balances = calculate_ending_balances(budget.periods, summary)

      {:ok,
       assign(socket,
         budget: budget,
         summary: summary,
         ending_balances: ending_balances,
         current_period_id: current_period_id(budget.periods)
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

  def current_period_id(periods, today \\ Date.utc_today()) do
    current = Enum.find(periods, fn p -> not Date.before?(p.end_date, today) end)

    cond do
      Enum.empty?(periods) ->
        nil

      Date.before?(today, List.first(periods).start_date) ->
        nil

      is_nil(current) ->
        List.last(periods).id

      true ->
        current.id
    end
  end

  def calculate_ending_balances([], _), do: %{}

  def calculate_ending_balances(periods, summary) do
    calculate_net = fn period_id ->
      Decimal.sub(
        get_in(summary, [period_id, :funding]) || Decimal.new("0"),
        get_in(summary, [period_id, :spending]) || Decimal.new("0")
      )
    end

    first_period = List.first(periods)

    Enum.zip(periods, Enum.drop(periods, 1))
    |> Enum.reduce(
      %{
        first_period.id => calculate_net.(first_period.id)
      },
      fn {%{id: previous_period_id}, %{id: period_id}}, acc ->
        balance = Decimal.add(Map.get(acc, previous_period_id), calculate_net.(period_id))
        Map.put(acc, period_id, balance)
      end
    )
  end

  defp default_transaction(budget) do
    %BudgetTransaction{
      effective_date: Date.utc_today(),
      budget: budget
    }
  end
end
