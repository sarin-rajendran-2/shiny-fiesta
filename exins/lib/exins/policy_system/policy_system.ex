defmodule Exins.PolicySystem do
  @moduledoc """
  The Exins.PolicySystem domain contains resources related to insurance policies.
  """
  use Ash.Domain

  resources do
    resource Exins.PolicySystem.Policy do
      # Define an interface for calling resource actions.
      define :create_policy, action: :create
      define :list_policies, action: :read
      define :update_policy, action: :update
      define :destroy_policy, action: :destroy
      define :get_policy, args: [:id], action: :by_id
    end

    resource Exins.PolicySystem.Applicant
  end
end
