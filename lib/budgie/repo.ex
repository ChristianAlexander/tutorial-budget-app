defmodule Budgie.Repo do
  use Ecto.Repo,
    otp_app: :budgie,
    adapter: Ecto.Adapters.Postgres
end
