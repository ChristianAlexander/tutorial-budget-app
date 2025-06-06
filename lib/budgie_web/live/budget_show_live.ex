defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Repo
  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  def mount(%{"budget_id" => id} = params, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: [:creator, :periods, :collaborators]
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

  defp apply_action(%{assigns: %{live_action: :collaborators}} = socket, _params) do
    budget = Repo.preload(socket.assigns.budget, collaborators: :user)

    {:ok, join_link} =
      Tracking.ensure_join_link(budget)

    assign(socket, budget: budget, join_link: join_link)
  end

  defp apply_action(socket, _params), do: socket

  def handle_event("remove-collaborator", %{"user-id" => user_id}, socket) do
    %{budget: budget, current_user: current_user} = socket.assigns
    collaborator = Enum.find(budget.collaborators, &(&1.user_id == user_id))

    socket =
      if collaborator do
        Tracking.remove_budget_collaborator(collaborator)
        budget = Repo.preload(budget, [collaborators: :user], force: true)

        assign(socket, budget: budget)
      else
        socket
      end

    socket =
      if user_id == current_user.id do
        socket
        |> put_flash(:info, "You have been removed from the budget")
        |> push_navigate(to: ~p"/budgets", replace: true)
      else
        socket
      end

    {:noreply, socket}
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
