defmodule ExIns.PolicySystem.Policy do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :policy_number, :string
    attribute :status, :atom do
      constraints [one_of: [:quote, :in_force, :cancelled]]

      # The status defaulting to open makes sense
      default :quote

      # We also don't want status to ever be `nil`
      allow_nil? false
    end
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
    repo ExIns.Repo
  end
end
