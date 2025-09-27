defmodule Exins.Common.FullNameCalculation do
  @moduledoc """
  A module to format full names from name parts.
  """

  use Ash.Resource.Calculation

  @impl true
  # A callback to tell Ash what keys must be loaded/selected when running this calculation
  def load(_query, _opts, _context) do [:name_parts] end

  @impl true
  def calculate(names, _opts, %{arguments: %{separator: separator}}) do
    Enum.map(names, fn name ->
      if name.name_parts, do: name.name_parts |> Map.values |> Enum.join(separator)
    end)
  end
end
