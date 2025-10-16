defmodule ExinsWeb.ApplicantLive.Show do
  @moduledoc """
  This LiveView displays the details of a single applicant.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Applicant {@applicant.id}
        <:subtitle>This is a applicant record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/applicants"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/applicants/#{@applicant}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Applicant
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@applicant.id}</:item>

        <:item title="Contact">{@applicant.contact_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Applicant")
     |> assign(:applicant, Ash.get!(Exins.PolicySystem.Applicant, id))}
  end
end
