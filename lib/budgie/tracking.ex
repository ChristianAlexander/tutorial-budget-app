defmodule Budgie.Tracking do
  import Ecto.Query, warn: false

  alias Budgie.Repo
  alias Budgie.Tracking.Budget

  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end
end
