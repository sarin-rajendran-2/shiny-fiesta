defmodule Exins.Common.Name do
  @moduledoc """
  The Name resource.
  """

  use Ash.Resource,
  data_layer: :embedded

  actions do
    defaults [:destroy, :read, create: :*, update: :*]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :type, :string, allow_nil?: true, public?: true
    attribute :names, :map, allow_nil?: false, public?: true
  end
end
