defmodule Budgie.Repo.Migrations.CreateBudgetCollaborators do
  use Ecto.Migration

  def change do
    create table(:budget_collaborators, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      add :budget_id, references(:budgets, on_delete: :delete_all, type: :binary_id),
        primary_key: true

      timestamps(type: :utc_datetime)
    end

    create index(:budget_collaborators, [:budget_id])
  end
end
