defmodule Exins.Common.Calculations.FullAddress do
  use Ash.Resource.Calculation

  @impl true
  # A callback to tell Ash what keys must be loaded/selected when running this calculation
  def load(_query, _opts, _context) do [:address_parts] end

  def format_address(address, separator) do
    case address.address_parts do
      nil -> nil
      parts when is_map(parts) ->
        [
          case parts["street_address"] do
            street_addresses when is_list(street_addresses) -> Enum.join(street_addresses, separator)
            street_address -> street_address
          end,
          parts["city"],
          parts["state"],
          parts["post_code"],
          parts["postal_code"],
          parts["country"]
        ]
        |> Enum.filter(& &1) # Remove nil or empty parts
        |> Enum.join(separator)
      _ -> "Unexpected"
    end
  end

  @impl true
  def calculate(addresses, _opts, %{arguments: %{separator: separator}}) do
      Enum.map(addresses, &format_address(&1, separator))
  end
end

defmodule Exins.Common.Address do
  alias Exins.Common.Calculations.FullAddress
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
    calculate :full_address, :string, {FullAddress, []} do
      argument :separator, :string, default: ", "
    end
  end

  preparations do
    prepare build(load: [:full_address])
  end
end
