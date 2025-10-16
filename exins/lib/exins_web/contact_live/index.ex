defmodule ExinsWeb.ContactLive.Index do
  @moduledoc """
  This LiveView lists all contacts and provides actions to create, edit, and delete them.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Contacts
        <:actions>
          <.button variant="primary" navigate={~p"/contacts/new"}>
            <.icon name="hero-plus" /> New Contact
          </.button>
        </:actions>
      </.header>

      <.table
        id="contacts"
        rows={@streams.contacts}
        row_click={fn {_id, contact} -> JS.navigate(~p"/contacts/#{contact}") end}
      >
        <:col :let={{_id, contact}} label="Id">{contact.id}</:col>

        <:col :let={{_id, contact}} label="Contact type">{contact.contact_type}</:col>

        <:col :let={{_id, contact}} label="Addresses">{contact.addresses}</:col>

        <:col :let={{_id, contact}} label="Emails">{contact.emails}</:col>

        <:col :let={{_id, contact}} label="Names">{contact.names}</:col>

        <:col :let={{_id, contact}} label="Phones">{contact.phones}</:col>

        <:action :let={{_id, contact}}>
          <div class="sr-only">
            <.link navigate={~p"/contacts/#{contact}"}>Show</.link>
          </div>

          <.link navigate={~p"/contacts/#{contact}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, contact}}>
          <.link
            phx-click={JS.push("delete", value: %{id: contact.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Contacts")
     |> stream(:contacts, Ash.read!(Exins.Common.Contact))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Ash.get!(Exins.Common.Contact, id)
    Ash.destroy!(contact)

    {:noreply, stream_delete(socket, :contacts, contact)}
  end
end
