defmodule ExIns.PolicySystem do
  use Ash.Api

  resources do
    resource ExIns.PolicySystem.Policy
  end
end
