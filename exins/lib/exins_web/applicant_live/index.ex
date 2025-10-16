defmodule ExinsWeb.ApplicantLive.Index do
  @moduledoc """
  This LiveView lists all applicants and provides actions to create, edit, and delete them.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Applicants
        <:actions>
          <.button variant="primary" navigate={~p"/applicants/new"}>
            <.icon name="hero-plus" /> New Applicant
          </.button>
        </:actions>
      </.header>

      <.table
        id="applicants"
        rows={@streams.applicants}
        row_click={fn {_id, applicant} -> JS.navigate(~p"/applicants/#{applicant}") end}
      >
        <:col :let={{_id, applicant}} label="Id">{applicant.id}</:col>

        <:col :let={{_id, applicant}} label="Contact">{applicant.contact_id}</:col>

        <:action :let={{_id, applicant}}>
          <div class="sr-only">
            <.link navigate={~p"/applicants/#{applicant}"}>Show</.link>
          </div>

          <.link navigate={~p"/applicants/#{applicant}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, applicant}}>
          <.link
            phx-click={JS.push("delete", value: %{id: applicant.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Applicants")
     |> stream(:applicants, Ash.read!(Exins.PolicySystem.Applicant))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    applicant = Ash.get!(Exins.PolicySystem.Applicant, id)
    Ash.destroy!(applicant)

    {:noreply, stream_delete(socket, :applicants, applicant)}
  end
end
