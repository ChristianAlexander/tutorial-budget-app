defmodule BudgieWeb.JoinController do
  use BudgieWeb, :controller

  alias Budgie.Tracking

  def show_invitation(conn, %{"code" => code}) do
    current_user = Map.get(conn.assigns, :current_user)

    budget = Tracking.get_budget_by_join_code(code, preload: [:creator, :collaborators])

    cond do
      is_nil(budget) ->
        conn
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/")

      not is_nil(current_user) and budget.creator_id == current_user.id ->
        redirect(conn, to: ~p"/budgets/#{budget}")

      not is_nil(current_user) and
          Enum.any?(budget.collaborators, &(&1.user_id == current_user.id)) ->
        redirect(conn, to: ~p"/budgets/#{budget}")

      true ->
        conn
        |> put_session(:user_return_to, current_path(conn))
        |> render(:show_invitation, budget: budget, code: code)
    end
  end

  def join(conn, %{"code" => code}) do
    current_user = conn.assigns.current_user

    budget =
      Tracking.get_budget_by_join_code(code)

    if budget == nil do
      conn
      |> put_flash(:error, "Budget not found")
      |> redirect(to: ~p"/")
    else
      if current_user.id != budget.creator_id do
        Tracking.ensure_budget_collaborator(budget, current_user)
      end

      redirect(conn, to: ~p"/budgets/#{budget}")
    end
  end
end
