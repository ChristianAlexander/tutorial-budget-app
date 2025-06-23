defmodule Budgie.Tracking.Forms.CreateBudget do
  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__
  alias Budgie.Tracking.Budget
  alias Budgie.Tracking.BudgetTransaction
  alias Budgie.Repo

  @maximum_period_funding_amount 100_000

  embedded_schema do
    field :period_funding_amount, :decimal
    embeds_one(:budget, Budget)
  end

  def new(schema \\ %CreateBudget{}) do
    changeset(schema, %{})
  end

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:period_funding_amount])
    |> validate_number(:period_funding_amount,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: @maximum_period_funding_amount
    )
    |> cast_embed(:budget, with: &Budget.changeset/2)
  end

  def submit(form, attrs) do
    result =
      form.source.data
      |> changeset(attrs)
      |> Ecto.Changeset.apply_action(:insert)

    with {:ok, data} <- result do
      data
      |> construct_multi()
      |> Repo.transaction()
    end
  end

  defp construct_multi(data) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:budget, data.budget)
    |> Ecto.Multi.run(:fund_budget, fn repo, %{budget: budget} ->
      fund_budget_if_necessary(repo, budget, data)
    end)
  end

  defp fund_budget_if_necessary(_repo, _budget, %{period_funding_amount: nil}), do: {:ok, []}

  defp fund_budget_if_necessary(repo, budget, %{period_funding_amount: amount}) do
    transactions =
      Enum.map(budget.periods, fn period ->
        BudgetTransaction.changeset(
          %BudgetTransaction{},
          %{
            budget_id: budget.id,
            type: :funding,
            amount: amount,
            effective_date: period.start_date,
            description: "Recurring funding"
          },
          budget
        )
        |> repo.insert!()
      end)

    {:ok, transactions}
  end
end
