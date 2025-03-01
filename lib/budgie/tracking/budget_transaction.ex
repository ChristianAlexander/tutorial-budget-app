defmodule Budgie.Tracking.BudgetTransaction do
  use Ecto.Schema
  import Ecto.Changeset

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
  def changeset(budget_transaction, attrs) do
    budget_transaction
    |> cast(attrs, [:effective_date, :type, :amount, :description, :budget_id])
    |> validate_required([:effective_date, :type, :amount, :description, :budget_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
  end
end
