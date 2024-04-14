defmodule ExIns.Repo do
  use AshPostgres.Repo, otp_app: :exins

  # Installs Postgres extensions that ash commonly uses
  def installed_extensions do
    [AshMoney.AshPostgresExtension, "uuid-ossp", "citext"]
  end
end
