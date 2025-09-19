defmodule Exins.PolicySystem.Policy do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  @doc """
  Represents an insurance policy.
  """

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    attribute :id, :uuid do
      primary_key? true
      allow_nil? false
      description "The system generated unique id for the policy record"
    end

    # Embedded resource named `Doc` (PolicyDocument)
    attribute :doc, Exins.PolicySystem.PolicyDocument do
      public? true
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  code_interface do
    define_for ExIns.PolicySystem
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
    define :get_by_id, args: [:id], action: :by_id
  end

  postgres do
    table "policies"
    repo Exins.Repo
  end
end
