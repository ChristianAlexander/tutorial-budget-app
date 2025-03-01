defmodule Budgie.Repo.Migrations.CreateBudgetTransactions do
  use Ecto.Migration

  def change do
    create table(:budget_transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :effective_date, :date
      add :type, :string
      add :amount, :decimal
      add :description, :text
      add :budget_id, references(:budgets, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:budget_transactions, [:budget_id])
  end
end
