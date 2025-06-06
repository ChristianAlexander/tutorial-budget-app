defmodule Budgie.Repo.Migrations.CreateBudgetJoinLinks do
  use Ecto.Migration

  def change do
    create table(:budget_join_links, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :budget_id, references(:budgets, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:budget_join_links, [:budget_id])
    create unique_index(:budget_join_links, [:code])
  end
end
