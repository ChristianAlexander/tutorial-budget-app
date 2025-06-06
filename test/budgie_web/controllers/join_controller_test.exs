defmodule BudgieWeb.JoinControllerTest do
  use BudgieWeb.ConnCase, async: true

  setup do
    join_link = insert(:budget_join_link)

    %{join_link: join_link, budget: join_link.budget, creator: join_link.budget.creator}
  end

  describe "GET /join/:code" do
    test "redirects to root when code is invalid", %{conn: conn} do
      conn = get(conn, ~p"/join/invalid")

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Budget not found"
    end

    test "redirects to budget when joining as creator", %{
      conn: conn,
      join_link: join_link,
      budget: budget,
      creator: creator
    } do
      conn =
        conn
        |> log_in_user(creator)
        |> get(~p"/join/#{join_link.code}")

      assert redirected_to(conn) == ~p"/budgets/#{budget}"
    end

    test "shows join page when unauthenticated", %{
      conn: conn,
      join_link: join_link,
      budget: budget,
      creator: creator
    } do
      conn = get(conn, ~p"/join/#{join_link.code}")

      html = html_response(conn, 200)

      assert html =~ html_escape("Collaborate on #{creator.name}’s budget")
      assert html =~ budget.name
      assert html =~ budget.description
      assert html =~ "You'll need to create an account"
    end

    test "shows join page when signed in", %{
      conn: conn,
      join_link: join_link,
      budget: budget,
      creator: creator
    } do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/join/#{join_link.code}")

      html = html_response(conn, 200)

      assert html =~ html_escape("Collaborate on #{creator.name}’s budget")
      assert html =~ budget.name
      assert html =~ budget.description
      assert html =~ user.email
      refute html =~ "You'll need to create an account"
    end
  end
end
