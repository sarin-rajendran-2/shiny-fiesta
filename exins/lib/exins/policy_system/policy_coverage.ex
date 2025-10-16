defmodule Exins.PolicySystem.PolicyCoverage do
  @moduledoc """
  Represents a coverage within an insurance policy.

  It is an embedded resource, meaning it is not stored in its own table
  but is embedded within other resources.
  """

  use Ash.Resource, data_layer: :embedded

  attributes do
    integer_primary_key :id do
      public? true
    end

    attribute :name, :ci_string do
      public? true
      description "The name of the coverage."
    end

    attribute :description, :string do
      public? true
      description "The description of the coverage."
    end

    attribute :limit, :money do
      public? true
      description "The coverage limit."
    end

    attribute :deductible, :money do
      public? true
      description "The deductible amount."
    end

    attribute :tax, :money do
      public? true
      description "The tax associated with this coverage."
    end
  end
end
