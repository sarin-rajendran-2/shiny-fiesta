defmodule Exins.PolicySystem do
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
  end
end
