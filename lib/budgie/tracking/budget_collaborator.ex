defmodule Budgie.Tracking.BudgetCollaborator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id
  schema "budget_collaborators" do
    belongs_to :user, Budgie.Accounts.User, type: :binary_id, primary_key: true
    belongs_to :budget, Budgie.Tracking.Budget, type: :binary_id, primary_key: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget_collaborator, attrs) do
    budget_collaborator
    |> cast(attrs, [:user_id, :budget_id])
    |> validate_required([:user_id, :budget_id])
  end
end
