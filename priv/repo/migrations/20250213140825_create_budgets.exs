defmodule Budgie.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :creator_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:budgets, [:creator_id])

    create constraint(:budgets, :budget_end_after_start,
             check: "end_date > start_date",
             comment: "Budget must end after its start date"
           )
  end
end
