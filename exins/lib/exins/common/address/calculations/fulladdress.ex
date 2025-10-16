defmodule Exins.Common.FullAddressCalculation do
  @moduledoc """
  This module defines a calculation for formatting a full address string.
  """
  use Ash.Resource.Calculation

  @doc """
  Specifies that the `address_parts` attribute must be loaded for this calculation.

  ## Parameters
    - `_query`: The Ash query.
    - `_opts`: A keyword list of options.
    - `_context`: The context map.

  ## Returns
    - A list of atoms representing the required keys.
  """
  @impl true
  def load(_query, _opts, _context) do
    [:address_parts]
  end

  @doc """
  Formats an address into a single string.

  ## Parameters
    - `address`: The address resource.
    - `separator`: The separator string to use between address parts.

  ## Returns
    - A formatted address string.
  """
  def format_address(address, separator) do
    case address.address_parts do
      nil ->
        nil

      parts when is_map(parts) ->
        [
          case parts["street_address"] do
            street_addresses when is_list(street_addresses) ->
              Enum.join(street_addresses, separator)

            street_address ->
              street_address
          end,
          parts["city"],
          parts["state"],
          parts["post_code"],
          parts["postal_code"],
          parts["country"]
        ]
        |> Enum.filter(& &1)
        |> Enum.join(separator)

      _ ->
        "Unexpected"
    end
  end

  @doc """
  Calculates the full address string for a list of addresses.

  ## Parameters
    - `addresses`: A list of address resources.
    - `_opts`: A keyword list of options.
    - `context`: The context map, containing the separator argument.

  ## Returns
    - A list of formatted address strings.
  """
  @impl true
  def calculate(addresses, _opts, %{arguments: %{separator: separator}}) do
    Enum.map(addresses, &format_address(&1, separator))
  end
end
