defmodule Budgie.Tracking.BudgetTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  @maximum_transaction_amount 100_000

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_transactions" do
    field :type, Ecto.Enum, values: [:funding, :spending]
    field :description, :string
    field :effective_date, :date
    field :amount, :decimal
    belongs_to :budget, Budgie.Tracking.Budget

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget_transaction, attrs, budget) do
    budget_transaction
    |> cast(attrs, [:effective_date, :type, :amount, :description, :budget_id])
    |> validate_required([:effective_date, :type, :amount, :description, :budget_id])
    |> validate_number(:amount,
      greater_than: 0,
      less_than_or_equal_to: @maximum_transaction_amount
    )
    |> validate_transaction_date_in_budget_range(budget)
  end

  defp validate_transaction_date_in_budget_range(cs, %Budgie.Tracking.Budget{
         start_date: start_date,
         end_date: end_date
       }) do
    effective_date = get_field(cs, :effective_date)

    cond do
      is_nil(effective_date) ->
        cs

      Date.before?(effective_date, start_date) ->
        add_error(cs, :effective_date, "must be after the budget's start")

      Date.after?(effective_date, end_date) ->
        add_error(cs, :effective_date, "must be before the budget's end")

      true ->
        cs
    end
  end
end
