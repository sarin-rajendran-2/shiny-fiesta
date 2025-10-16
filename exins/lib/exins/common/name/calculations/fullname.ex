defmodule Exins.Common.FullNameCalculation do
  @moduledoc """
  A module to format full names from name parts.
  """

  use Ash.Resource.Calculation

  @doc """
  Specifies that the `name_parts` attribute must be loaded for this calculation.

  ## Parameters
    - `_query`: The Ash query.
    - `_opts`: A keyword list of options.
    - `_context`: The context map.

  ## Returns
    - A list of atoms representing the required keys.
  """
  @impl true
  def load(_query, _opts, _context) do
    [:name_parts]
  end

  @doc """
  Calculates the full name string for a list of names.

  ## Parameters
    - `names`: A list of name resources.
    - `_opts`: A keyword list of options.
    - `context`: The context map, containing the separator argument.

  ## Returns
    - A list of formatted name strings.
  """
  @impl true
  def calculate(names, _opts, %{arguments: %{separator: separator}}) do
    Enum.map(names, fn name ->
      if name.name_parts, do: name.name_parts |> Map.values |> Enum.join(separator)
    end)
  end
end
