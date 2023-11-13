defmodule Exins.Repo do
  use Ecto.Repo,
    otp_app: :exins,
    adapter: Ecto.Adapters.Postgres
end
