defmodule Exins.Repo do
  @moduledoc """
  The Exins.Repo module is the Ecto repository for the application.

  It uses AshPostgres.Repo and is configured to use the `:exins` OTP app.
  """
  use AshPostgres.Repo, otp_app: :exins

  @doc """
  Returns a list of PostgreSQL extensions that Ash commonly uses.

  ## Returns
    - A list of strings, where each string is the name of a PostgreSQL extension.
  """
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end

  @doc """
  Returns the minimum required PostgreSQL version.

  ## Returns
    - A `Version` struct representing the minimum required PostgreSQL version.
  """
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
