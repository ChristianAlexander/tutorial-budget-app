defmodule Budgie.Tracking.BudgetJoinLink do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budget_join_links" do
    field :code, :string, autogenerate: {__MODULE__, :random_join_code, []}
    belongs_to :budget, Budgie.Tracking.Budget

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget_join_link, attrs) do
    budget_join_link
    |> cast(attrs, [:budget_id])
    |> validate_required([:budget_id])
    |> unique_constraint([:budget_id])
    |> unique_constraint([:code])
  end

  def random_join_code() do
    Nanoid.generate()
  end
end
