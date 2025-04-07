defmodule Budgie.Repo.Migrations.CreateBudgetPeriods do
  use Ecto.Migration

  def change do
    create table(:budget_periods, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_date, :date
      add :end_date, :date
      add :budget_id, references(:budgets, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:budget_periods, [:budget_id, :start_date])

    create constraint(:budget_periods, :end_after_start,
             check: "end_date > start_date",
             comment: "Period must end after its start date"
           )
  end
end
