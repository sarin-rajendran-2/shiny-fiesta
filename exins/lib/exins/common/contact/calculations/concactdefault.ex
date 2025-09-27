defmodule Exins.Common.ContactDefaultCalculation do
  use Ash.Resource.Calculation

  defp has_tag?(attr, findTag) do
    cond do
      !(attr && Map.get(attr, :tags)) -> false
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

  @impl true
  def load(_query, opts, _context) do
    [opts[:attribute]]
  end

  @impl true
  def calculate(records, opts, %{arguments: %{tag: tag}}) do
    records
    |> Enum.map(fn record ->
      attrs = record
      |> Map.from_struct
      |> Map.get(opts[:attribute])

      if attrs && is_list(attrs) do
        attrs |> Enum.reduce_while(nil, &get_default(&1, &2, tag))
      end
    end)
  end
end
