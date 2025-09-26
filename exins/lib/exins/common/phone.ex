defmodule Exins.Common.Phone do
  @moduledoc """
  The Phone resource.
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
    attribute :number_parts, :map, allow_nil?: false, public?: true
  end

  calculations do
    calculate :full_phone_number, :string, expr("+" <> number_parts[:country_code] <> number_parts[:phone_number])
  end

  preparations do
    prepare build(load: [:full_phone_number])
  end
end
