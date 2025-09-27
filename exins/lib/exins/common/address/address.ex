defmodule Exins.Common.Address do
  alias Exins.Common.FullAddressCalculation
  @moduledoc """
  The Address resource.
  """

  use Ash.Resource,
  data_layer: :embedded,
  embed_nil_values?: false

  actions do
    defaults [:destroy, :read, create: :*, update: :*]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :tags, {:array, :string}, allow_nil?: true, public?: true
    attribute :address_parts, :map, allow_nil?: false, public?: true
  end

  calculations do
    calculate :full_address, :string, {FullAddressCalculation, []} do
      argument :separator, :string, default: ", "
    end
  end

  preparations do
    prepare build(load: [:full_address])
  end
end
