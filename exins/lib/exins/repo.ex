defmodule ExIns.Repo do
  use AshPostgres.Repo, otp_app: :exins

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
