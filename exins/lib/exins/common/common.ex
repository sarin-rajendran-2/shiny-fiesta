defmodule Exins.Common do
  @moduledoc """
  The Exins.Common domain contains common resources used across the application.

  It currently includes the `Exins.Common.Contact` resource.
  """
  use Ash.Domain

  resources do
    resource Exins.Common.Contact
  end
end
