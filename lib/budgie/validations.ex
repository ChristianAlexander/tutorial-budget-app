defmodule Budgie.Validations do
  import Ecto.Changeset

  def validate_date_month_boundaries(%Ecto.Changeset{valid?: false} = cs), do: cs

  def validate_date_month_boundaries(%Ecto.Changeset{} = cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :end_date)

    cs =
      if start_date != Date.beginning_of_month(start_date) do
        add_error(cs, :start_date, "must be the beginning of a month")
      else
        cs
      end

    if end_date != Date.end_of_month(end_date) do
      add_error(cs, :end_date, "must be the end of a month")
    else
      cs
    end
  end
end
