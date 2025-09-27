defmodule Exins.Common.Name do
  @moduledoc """
  The Name resource.
  """

  use Ash.Resource,
  data_layer: :embedded,
  embed_nil_values?: false
  alias Exins.Common.FullNameCalculation

  actions do
    defaults [:destroy, :read, create: :*, update: :*]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :tags, {:array, :string}, allow_nil?: true, public?: true
    attribute :name_parts, :map, allow_nil?: false, public?: true
  end

  calculations do
    calculate :full_name, :string, {Exins.Common.FullNameCalculation, []} do
      argument :separator, :string, default: " "
    end
  end

  preparations do
    prepare build(load: [:full_name])
  end
end
