defmodule ExinsWeb.ContactLive.Form do
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage contact records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="contact-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:contact_type]}
          type="select"
          label="Contact type"
          options={
            Ash.Resource.Info.attribute(Exins.Common.Contact, :contact_type).constraints[:one_of]
          }
        />
        <.input
          field={@form[:addresses]}
          type="select"
          multiple
          label="Addresses"
          options={[]}
        />
        <.input
          field={@form[:emails]}
          type="select"
          multiple
          label="Emails"
          options={[]}
        />
        <.input
          field={@form[:names]}
          type="select"
          multiple
          label="Names"
          options={[]}
        />
        <.input
          field={@form[:phones]}
          type="select"
          multiple
          label="Phones"
          options={[]}
        />

        <.button phx-disable-with="Saving..." variant="primary">Save Contact</.button>
        <.button navigate={return_path(@return_to, @contact)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    contact =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Exins.Common.Contact, id)
      end

    action = if is_nil(contact), do: "New", else: "Edit"
    page_title = action <> " " <> "Contact"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(contact: contact)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, contact_params))}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: contact_params) do
      {:ok, contact} ->
        notify_parent({:saved, contact})

        socket =
          socket
          |> put_flash(:info, "Contact #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, contact))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{contact: contact}} = socket) do
    form =
      if contact do
        AshPhoenix.Form.for_update(contact, :update, as: "contact")
      else
        AshPhoenix.Form.for_create(Exins.Common.Contact, :create, as: "contact")
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _contact), do: ~p"/contacts"
  defp return_path("show", contact), do: ~p"/contacts/#{contact.id}"
end
