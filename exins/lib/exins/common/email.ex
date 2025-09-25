defmodule Exins.Common.Email do
  @moduledoc """
  The Email resource.
  """

  use Ash.Resource,
  data_layer: :embedded

  actions do
    defaults [:destroy, :read, create: :*, update: :*]
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :tags, {:array, :string}, allow_nil?: true, public?: true
    attribute :email, {:array, :string}, allow_nil?: false, public?: true
  end
end
