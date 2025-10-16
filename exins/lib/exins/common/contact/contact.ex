defmodule Exins.Common.Contact do
  alias Exins.Common.ContactDefaultCalculation
  alias Exins.Common.{Address, Email, Name, Phone}

  @moduledoc """
  The Contact resource represents a contact, which can be an individual or an organization.

  It contains information such as addresses, emails, names, and phone numbers.
  """

  use Ash.Resource,
    domain: Exins.Common,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:destroy, :read, create: :*]

    update :update do
      accept :*
      primary? true
      require_atomic? false
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :seq_number, :integer do
      allow_nil? false
      generated? true
      public? false
    end

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
    calculate :default_address, Address, {ContactDefaultCalculation, [attribute: :addresses]} do
      argument :tag, :string, default: "Default"
    end

    calculate :default_email, Email, {ContactDefaultCalculation, [attribute: :emails]} do
      argument :tag, :string, default: "Default"
    end

    calculate :default_name, Name, {ContactDefaultCalculation, [attribute: :names]} do
      argument :tag, :string, default: "Default"
    end

    calculate :default_phone, Phone, {ContactDefaultCalculation, [attribute: :phones]} do
      argument :tag, :string, default: "Default"
    end
  end

  identities do
    identity :unique_seq_number, [:seq_number]
  end

  postgres do
    table "contacts"
    repo Exins.Repo
  end
end
