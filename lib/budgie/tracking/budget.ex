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

    has_many :collaborators, Budgie.Tracking.BudgetCollaborator
    has_many :periods, Budgie.Tracking.BudgetPeriod
    has_one :join_link, Budgie.Tracking.BudgetJoinLink

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :description, :start_date, :end_date, :creator_id])
    |> validate_required([:name, :start_date, :end_date, :creator_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_end_date_after_start_date()
    |> Budgie.Validations.validate_date_month_boundaries()
    |> add_periods()
  end

  defp add_periods(%{valid?: false} = changeset), do: changeset

  defp add_periods(changeset) do
    start_date = Ecto.Changeset.get_field(changeset, :start_date)
    end_date = Ecto.Changeset.get_field(changeset, :end_date)

    changeset
    |> Ecto.Changeset.change(%{periods: months_between(start_date, end_date)})
    |> Ecto.Changeset.cast_assoc(:periods)
  end

  defp validate_end_date_after_start_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if not is_nil(start_date) and not is_nil(end_date) and
         Date.compare(start_date, end_date) != :lt do
      add_error(changeset, :end_date, "must end after start date")
    else
      changeset
    end
  end

  def months_between(start_date, end_date, acc \\ []) do
    end_of_month = Date.end_of_month(start_date)

    # If we have reached the end of the timespan
    if not Date.after?(end_date, end_of_month) do
      Enum.reverse([%{start_date: start_date, end_date: end_of_month} | acc])
    else
      months_between(
        Date.add(end_of_month, 1),
        end_date,
        [%{start_date: start_date, end_date: end_of_month} | acc]
      )
    end
  end
end
