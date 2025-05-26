defmodule BudgieWeb.PeriodShowLiveTest do
  use BudgieWeb.ConnCase, async: true

  alias Budgie.Repo
  alias Budgie.Tracking.BudgetTransaction

  import Phoenix.LiveViewTest

  setup do
    budget = insert(:budget)

    period =
      insert(:budget_period, budget: budget, start_date: ~D[2025-01-01], end_date: ~D[2025-01-31])

    %{budget: budget, period: period, user: budget.creator}
  end

  describe "Show period" do
    test "shows period when it exists", %{conn: conn, user: user, budget: budget, period: period} do
      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}")

      assert html =~ budget.name
    end

    test "shows empty state when no transactions exist", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period
    } do
      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}")

      assert html =~ "No transactions yet"
    end

    test "shows transaction when it exists", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period
    } do
      transaction = insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-15])

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}")

      assert html =~ transaction.description
    end

    test "redirects to budget list page when period does not exist", %{conn: conn, user: user} do
      fake_budget_id = Ecto.UUID.generate()
      fake_period_id = Ecto.UUID.generate()

      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{fake_budget_id}/periods/#{fake_period_id}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Not found"} = conn.assigns.flash
    end

    test "redirects to budget list page when period ID is not a uuid", %{conn: conn, user: user} do
      fake_budget_id = Ecto.UUID.generate()
      fake_period_id = "invalid_uuid"

      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{fake_budget_id}/periods/#{fake_period_id}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Not found"} = conn.assigns.flash
    end

    test "redirects to budget list page when budget ID is not a uuid", %{conn: conn, user: user} do
      fake_budget_id = "invalid_uuid"
      fake_period_id = Ecto.UUID.generate()

      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{fake_budget_id}/periods/#{fake_period_id}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Not found"} = conn.assigns.flash
    end

    test "redirects to budget list page when budget is hidden from the user", %{
      conn: conn,
      budget: budget,
      period: period
    } do
      other_user = insert(:user)

      conn = log_in_user(conn, other_user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}")
        |> follow_redirect(conn, ~p"/budgets")

      assert %{"error" => "Not found"} = conn.assigns.flash
    end
  end

  describe "Create transaction modal" do
    test "modal is presented", %{conn: conn, user: user, budget: budget, period: period} do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}/new-transaction")

      assert has_element?(lv, "#transaction-modal")
    end

    test "creates a transaction", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}/new-transaction")

      params = params_for(:budget_transaction)

      form =
        form(lv, "#transaction-modal form", %{
          "transaction" => params
        })

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn)

      assert html =~ "Transaction created"
      assert html =~ params.description
    end
  end

  describe "Edit transaction modal" do
    setup %{budget: budget} do
      transaction = insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-15])

      %{transaction: transaction}
    end

    test "shows edit transaction modal", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period,
      transaction: transaction
    } do
      conn = log_in_user(conn, user)

      {:ok, lv, _html} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}/transactions/#{transaction}/edit")

      assert has_element?(lv, "#transaction-modal")

      assert has_element?(
               lv,
               ~s|#transaction-modal input[name='transaction[description]'][value='#{transaction.description}']|
             )
    end

    test "redirects on invalid transaction id", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period
    } do
      conn = log_in_user(conn, user)

      {:ok, conn} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}/transactions/invalid/edit")
        |> follow_redirect(conn, ~p"/budgets/#{budget}/periods/#{period}")

      assert %{"error" => "Transaction not found"} = conn.assigns.flash
    end

    test "validation errors are presented when form is changed with invalid input", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period,
      transaction: transaction
    } do
      conn = log_in_user(conn, user)

      {:ok, lv, _html} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}/transactions/#{transaction}/edit")

      params = params_for(:budget_transaction, amount: Decimal.new("-42"))

      form =
        form(lv, "#transaction-modal form", %{
          "transaction" => params
        })

      html = render_change(form)

      assert html =~ "must be greater than 0"
    end

    test "validation errors are presented when form is submitted with invalid input", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period,
      transaction: transaction
    } do
      conn = log_in_user(conn, user)

      {:ok, lv, _html} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}/transactions/#{transaction}/edit")

      params = params_for(:budget_transaction, amount: Decimal.new("-42"))

      form =
        form(lv, "#transaction-modal form", %{
          "transaction" => params
        })

      html = render_submit(form)

      assert html =~ "must be greater than 0"
    end

    test "updates transaction", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period,
      transaction: transaction
    } do
      conn = log_in_user(conn, user)

      {:ok, lv, _html} =
        live(conn, ~p"/budgets/#{budget}/periods/#{period}/transactions/#{transaction}/edit")

      new_amount = (:rand.uniform(5000) / 100) |> Decimal.from_float()

      params = params_for(:budget_transaction, amount: new_amount)

      form =
        form(lv, "#transaction-modal form", %{
          "transaction" => params
        })

      {:ok, _lv, html} =
        render_submit(form)
        |> follow_redirect(conn)

      assert html =~ "Transaction updated"

      transaction = Repo.get(BudgetTransaction, transaction.id)
      assert transaction.amount == new_amount
    end
  end

  describe "Delete transaction" do
    setup %{budget: budget} do
      transaction = insert(:budget_transaction, budget: budget, effective_date: ~D[2025-01-15])

      %{transaction: transaction}
    end

    test "deletes transaction", %{
      conn: conn,
      user: user,
      budget: budget,
      period: period,
      transaction: transaction
    } do
      conn = log_in_user(conn, user)
      {:ok, lv, html} = live(conn, ~p"/budgets/#{budget}/periods/#{period}")

      assert html =~ transaction.description

      delete_button =
        element(
          lv,
          ~s|button[phx-click="delete_transaction"][phx-value-id="#{transaction.id}"]|
        )

      {:ok, _lv, html} =
        render_click(delete_button)
        |> follow_redirect(conn, ~p"/budgets/#{budget}/periods/#{period}")

      refute html =~ transaction.description
      assert html =~ "Transaction deleted"
    end
  end
end
