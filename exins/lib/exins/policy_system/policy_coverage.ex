defmodule Exins.PolicySystem.PolicyCoverage do
  use Ash.Resource, data_layer: :embedded

  @doc """
  Represents a coverage within an insurance policy.
  """
  attributes do
    integer_primary_key :id

    attribute :name, :ci_string do
      description "The name of the coverage."
    end

    attribute :description, :string do
      description "The description of the coverage."
    end

    attribute :limit, :money do
      public? true
      description "The coverage limit."
    end

    attribute :deductible, :money do
      description "The deductible amount."
    end

    attribute :tax, :money do
      description "The tax associated with this coverage."
    end
  end
end
