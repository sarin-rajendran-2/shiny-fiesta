defmodule Exins.PolicySystem.Policy do
  use Ash.Resource,
    domain: Exins.PolicySystem,
    data_layer: AshPostgres.DataLayer
    # authorizers: [Ash.Policy.Authorizer]

  @doc """
  Represents an insurance policy.
  """
  alias Exins.PolicySystem.Applicant
  alias Exins.PolicySystem.PolicyDocument

  @default_term [year: 1]
  @lines_of_business [:auto, :home, :medical_indenmity]
  @statuses [:quote, :in_force, :cancelled]

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:*]
      argument :applicant, :map, allow_nil?: true

      change fn changeset, _context ->
        changeset
        |> Ash.Changeset.change_new_attribute_lazy(:expiry_date, fn ->
          effectiveDate = case changeset |> Ash.Changeset.get_attribute(:effective_date) do
            nil -> Date.utc_today()
            someDate -> someDate
          end
          Date.shift(effectiveDate, @default_term)
        end)
      end

      change set_context(%{line_of_business: arg(:line_of_business)})

      change manage_relationship(:applicant, :applicant, type: :create)
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
      default &Date.utc_today/0
      public? true
    end
    attribute :expiry_date, :date do
      allow_nil? false
      public? true
    end
    attribute :line_of_business, :atom do
      allow_nil? false
      constraints [one_of: @lines_of_business]
      public? true
    end
    attribute :status, :atom do
      public? true
      description "The status of the policy"
      constraints [one_of: @statuses]
      default :quote
      allow_nil? false
    end
    # Embedded resource named `Doc` (PolicyDocument)
    attribute :doc, PolicyDocument do
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

  relationships do
    belongs_to :applicant, Applicant do
      public? true
      allow_nil? true
    end
  end

  validations do
      validate compare(:expiry_date, greater_than_or_equal_to: :effective_date)
  end
end
