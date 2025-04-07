defmodule Budgie.Tracking.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "budgets" do
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :creator, Budgie.Accounts.User

    has_many :periods, Budgie.Tracking.BudgetPeriod

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :description, :start_date, :end_date, :creator_id])
    |> validate_required([:name, :start_date, :end_date, :creator_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 500)
    |> check_constraint(:end_date,
      name: :budget_end_after_start,
      message: "must end after start date"
    )
  end
end
