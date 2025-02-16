defmodule BudgieWeb.BudgetListLiveTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.TrackingFixtures

  alias Budgie.Tracking

  setup do
    user = Budgie.AccountsFixtures.user_fixture()

    %{user: user}
  end

  describe "Index view" do
    test "shows budget when one exists", %{conn: conn, user: user} do
      budget = budget_fixture(%{creator_id: user.id})

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets")

      assert html =~ budget.name
      assert html =~ budget.description
    end
  end
end
