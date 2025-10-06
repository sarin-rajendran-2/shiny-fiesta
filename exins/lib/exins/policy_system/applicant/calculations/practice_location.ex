defmodule Exins.Common.PracticeLocationCalculation do
  @moduledoc """
  Calculation to extract the practice location from an applicant's contact information.
  """
  use Ash.Resource.Calculation

  alias Exins.Common.Contact
  alias Exins.PolicySystem.Applicant

  @impl true
  def load(_query, _opts, _context) do
    [contact: [default_address: [tag: "Practice Location"]]]
  end

  defp get_practice_location(%Applicant{contact: %Contact{default_address: practice_location }}), do: practice_location
  defp get_practice_location(_), do: nil

  @impl true
  def calculate(applicantRecords, _opts, _context) do
    applicantRecords |> Enum.map(&get_practice_location/1)
  end
end
