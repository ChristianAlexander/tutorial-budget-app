defmodule BudgieWeb.BudgetListLive do
  use BudgieWeb, :live_view

  alias Budgie.Tracking

  def mount(_params, _session, socket) do
    budgets =
      Tracking.list_budgets(
        user: socket.assigns.current_user,
        preload: :creator
      )

    socket = assign(socket, budgets: budgets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.modal
      :if={@live_action == :new}
      id="create-budget-modal"
      on_cancel={JS.navigate(~p"/budgets", replace: true)}
      show
    >
      <.live_component
        module={BudgieWeb.CreateBudgetDialog}
        id="create-budget"
        current_user={@current_user}
      />
    </.modal>
    <div class="flex justify-end">
      <.link
        navigate={~p"/budgets/new"}
        class="bg-gray-100 text-gray-700 hover:bg-gray-200 hover:text-gray-800 px-3 py-2 rounded-lg flex items-center gap-2"
      >
        <.icon name="hero-plus" class="h-4 w-4" />
        <span>New Budget</span>
      </.link>
    </div>
    <.table id="budgets" rows={@budgets}>
      <:col :let={budget} label="Name">{budget.name}</:col>
      <:col :let={budget} label="Description">{budget.description}</:col>
      <:col :let={budget} label="Start Date">{budget.start_date}</:col>
      <:col :let={budget} label="End Date">{budget.end_date}</:col>
      <:col :let={budget} label="Creator Name">{budget.creator.name}</:col>
    </.table>
    """
  end
end
