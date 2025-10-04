defmodule Exins.PolicySystem.Applicant do
  use Ash.Resource,
  domain: Exins.PolicySystem,
  data_layer: AshPostgres.DataLayer

  @moduledoc """
  The Applicant resource.
  """

  require Ash.Query
  alias Exins.Common.{Address, Contact, PracticeLocationCalculation}

  actions do
    defaults [:destroy, :read, update: :*]

    create :create do
      primary? true
      argument :line_of_business, :atom
      argument :contact_id, :uuid
      argument :practice_location, :map, allow_nil?: true

      change manage_relationship(:contact_id, :contact, on_lookup: :relate, on_no_match: :error)

      change after_action(fn changeset, record, context ->
        practice_location = changeset
        |> Ash.Changeset.get_argument(:practice_location)
        practice_address = %{
          tags: ["Practice Location"],
          address_parts: practice_location
        }

        Exins.Common.Contact
        |> Ash.get!(record.contact_id)
        |> Ash.read_one!()
        |> Ash.Changeset.for_update(:update, %{addresses: [practice_address]})
        |> Ash.update!()

        {:ok, record}
      end), where: [argument_equals(:line_of_business, :medical_indemnity)]
    end
  end

  attributes do
    uuid_v7_primary_key :id

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :practice_location, Address, {PracticeLocationCalculation, []}
  end

  postgres do
    table "applicants"
    repo Exins.Repo
  end

  relationships do
    belongs_to :contact, Contact do
      public? true
      allow_nil? true
    end
  end

  validations do
    validate present(:practice_location), where: [argument_equals(:line_of_business, :medical_indemnity)]
  end
end
