defmodule ExinsWeb.ContactLive.Show do
  @moduledoc """
  This LiveView displays the details of a single contact.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Contact {@contact.id}
        <:subtitle>This is a contact record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/contacts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/contacts/#{@contact}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Contact
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@contact.id}</:item>

        <:item title="Contact type">{@contact.contact_type}</:item>

        <:item title="Addresses">{@contact.addresses}</:item>

        <:item title="Emails">{@contact.emails}</:item>

        <:item title="Names">{@contact.names}</:item>

        <:item title="Phones">{@contact.phones}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Contact")
     |> assign(:contact, Ash.get!(Exins.Common.Contact, id))}
  end
end
