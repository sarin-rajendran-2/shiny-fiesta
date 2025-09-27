defmodule Exins.Common.Contact do
  alias Exins.Common.Calculations.ContactDefault,
  alias Exins.Common.{Address, Email, Name, Phone}

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

    attribute :addresses, {:array, Address}, public?: true, allow_nil?: true
    attribute :emails, {:array, Email}, public?: true, allow_nil?: true
    attribute :names, {:array, Name}, public?: true, allow_nil?: false
    attribute :phones, {:array, Phone}, public?: true, allow_nil?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :default_address, Address, {ContactDefault, [attribute: :addresses]} do
      argument :tag, :string, default: "Default"
    end
    calculate :default_email, Email, {ContactDefault, [attribute: :emails]} do
      argument :tag, :string, default: "Default"
    end
    calculate :default_name, Name, {ContactDefault, [attribute: :names]} do
      argument :tag, :string, default: "Default"
    end
    calculate :default_phone, Phone, {ContactDefault, [attribute: :phones]} do
      argument :tag, :string, default: "Default"
    end
  end

  postgres do
    table "contacts"
    repo Exins.Repo
  end
end
