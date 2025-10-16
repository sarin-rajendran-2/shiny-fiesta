defmodule Exins.Common.PracticeLocationCalculation do
  @moduledoc """
  Calculation to extract the practice location from an applicant's contact information.
  """
  use Ash.Resource.Calculation

  alias Exins.Common.Contact
  alias Exins.PolicySystem.Applicant

  @doc """
  Specifies that the `contact` relationship with the `default_address`
  calculation (tagged as "Practice Location") must be loaded.

  ## Parameters
    - `_query`: The Ash query.
    - `_opts`: A keyword list of options.
    - `_context`: The context map.

  ## Returns
    - A list specifying the data to be loaded.
  """
  @impl true
  def load(_query, _opts, _context) do
    [contact: [default_address: [tag: "Practice Location"]]]
  end

  defp get_practice_location(%Applicant{contact: %Contact{default_address: practice_location}}),
    do: practice_location

  defp get_practice_location(_), do: nil

  @doc """
  Calculates the practice location for a list of applicant records.

  ## Parameters
    - `applicantRecords`: A list of applicant records.
    - `_opts`: A keyword list of options.
    - `_context`: The context map.

  ## Returns
    - A list of practice location addresses.
  """
  @impl true
  def calculate(applicantRecords, _opts, _context) do
    applicantRecords |> Enum.map(&get_practice_location/1)
  end
end
