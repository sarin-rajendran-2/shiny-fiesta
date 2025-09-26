defmodule Exins.Common.Name do
  @moduledoc """
  The Name resource.
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
    attribute :name_parts, :map, allow_nil?: false, public?: true
  end

  calculations do
    calculate :full_name, :string, expr(name_parts[:first_name] <> " " <> name_parts[:last_name])
  end

  preparations do
    prepare build(load: [:full_name])
  end
end
