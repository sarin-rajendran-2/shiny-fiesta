defmodule Exins.Common.ContactDefaultCalculation do
  @moduledoc """
  This module defines a calculation for finding the default attribute
  (e.g., address, email) for a contact based on a tag.
  """
  use Ash.Resource.Calculation

  defp has_tag?(attr, findTag) do
    cond do
      !(attr && Map.get(attr, :tags)) ->
        false

      true ->
        Map.get(attr, :tags)
        |> Enum.find(fn tag -> tag == findTag end)
    end
  end

  defp get_default(attr, acc, findTag) do
    cond do
      has_tag?(attr, findTag) -> {:halt, attr}
      is_nil(acc) -> {:cont, attr}
      !Map.get(acc, :tags) -> {:cont, acc}
      !Map.get(attr, :tags) -> {:cont, attr}
      true -> {:cont, acc}
    end
  end

  @doc """
  Specifies that the attribute being calculated must be loaded.

  ## Parameters
    - `_query`: The Ash query.
    - `opts`: A keyword list of options, containing the attribute name.
    - `_context`: The context map.

  ## Returns
    - A list containing the attribute name to be loaded.
  """
  @impl true
  def load(_query, opts, _context) do
    [opts[:attribute]]
  end

  @doc """
  Calculates the default attribute for a list of records.

  ## Parameters
    - `records`: A list of contact records.
    - `opts`: A keyword list of options, containing the attribute name.
    - `context`: The context map, containing the tag argument.

  ## Returns
    - A list of default attributes, one for each record.
  """
  @impl true
  def calculate(records, opts, %{arguments: %{tag: tag}}) do
    records
    |> Enum.map(fn record ->
      attrs =
        record
        |> Map.from_struct()
        |> Map.get(opts[:attribute])

      if attrs && is_list(attrs) do
        attrs |> Enum.reduce_while(nil, &get_default(&1, &2, tag))
      end
    end)
  end
end
