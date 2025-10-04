defmodule Exins.PolicySystem.Policy do
  use Ash.Resource,
    domain: Exins.PolicySystem,
    data_layer: AshPostgres.DataLayer
    # authorizers: [Ash.Policy.Authorizer]

  @doc """
  Represents an insurance policy.
  """

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:*]
      change fn changeset, _context ->
        IO.inspect(changeset)
        |> Ash.Changeset.change_new_attribute_lazy(:expiry_date, fn ->
          effectiveDate = case IO.inspect(Ash.Changeset.get_attribute(changeset, :effective_date)) do
            nil -> Date.utc_today()
            someDate -> someDate
          end
          Date.shift(effectiveDate, year: 1)
        end)
      end
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    update :update do
      accept [:*]
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
    attribute :effective_date, :date do
      allow_nil? false
      default Date.utc_today()
      public? true
    end
    attribute :expiry_date, :date do
      allow_nil? false
      public? true
    end
    attribute :line_of_business, :atom do
      allow_nil? false
      constraints [one_of: [:auto, :home]]
      public? true
    end
    # Embedded resource named `Doc` (PolicyDocument)
    attribute :doc, Exins.PolicySystem.PolicyDocument do
      public? true
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :policy_number, :ci_string, expr(fragment("concat(?, lpad(CAST(seq_number AS TEXT), 8, '0'))", type("POL", :string)))
  end

  identities do
    identity :unique_seq_number, [:seq_number]
  end

  postgres do
    table "policies"
    repo Exins.Repo
  end

  preparations do
    prepare build(load: [:policy_number])
  end

  validations do
      validate compare(:expiry_date, greater_than_or_equal_to: :effective_date)
  end
end
