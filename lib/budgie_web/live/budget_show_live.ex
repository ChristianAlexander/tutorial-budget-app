defmodule BudgieWeb.BudgetShowLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking

  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        user: socket.assigns.current_user,
        preload: :creator
      )

    if budget do
      {:ok, assign(socket, budget: budget)}
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

  def render(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :new_transaction}
      id="create-transaction-modal"
      on_cancel={JS.navigate(~p"/budgets/#{@budget}", replace: true)}
      show
    >
      <.live_component
        module={BudgieWeb.CreateTransactionDialog}
        id="create-transaction"
        budget={@budget}
      />
    </.modal>

    <div class="flex justify-between items-center">
      <div>{@budget.name} by {@budget.creator.name}</div>
      <.link
        navigate={~p"/budgets/#{@budget}/new-transaction"}
        class="bg-gray-100 text-gray-700 hover:bg-gray-200 hover:text-gray-800 px-3 py-2 rounded-lg flex items-center gap-2"
      >
        <.icon name="hero-plus" class="h-4 w-4" />
        <span>New Transaction</span>
      </.link>
    </div>
    """
  end
end
