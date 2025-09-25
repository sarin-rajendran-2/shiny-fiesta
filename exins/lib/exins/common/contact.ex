defmodule Exins.Common.Contact do
  @moduledoc """
  The Contact resource.
  """

  use Ash.Resource,
    domain: Exins.Common,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:destroy, :read, create: :*, update: :*]
  end

  attributes do
    uuid_v7_primary_key :id
    integer_primary_key :seq_number, public?: false
    attribute :contact_type, :atom do
      allow_nil? true
      public? true
      constraints [one_of: [:individual, :organization]]
    end

    attribute :emails, {:array, Exins.Common.Email}, public?: true, allow_nil?: true

    attribute :names, {:array, Exins.Common.Name}, public?: true, allow_nil?: false

    attribute :phones, {:array, Exins.Common.Phone}, public?: true, allow_nil?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  postgres do
    table "contacts"
    repo Exins.Repo
  end
end
