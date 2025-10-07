defmodule ExinsWeb.ApplicantLive.Form do
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage applicant records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="applicant-form"
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:line_of_business]} type="text" label="Line of business" /><.input
            field={@form[:contact_id]}
            type="text"
            label="Contact"
          /><.input field={@form[:practice_location]} type="text" label="Practice location" />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:contact_id]} type="text" label="Contact" />
        <% end %>

        <.button phx-disable-with="Saving..." variant="primary">Save Applicant</.button>
        <.button navigate={return_path(@return_to, @applicant)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    applicant =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Exins.PolicySystem.Applicant, id)
      end

    action = if is_nil(applicant), do: "New", else: "Edit"
    page_title = action <> " " <> "Applicant"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(applicant: applicant)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"applicant" => applicant_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, applicant_params))}
  end

  def handle_event("save", %{"applicant" => applicant_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: applicant_params) do
      {:ok, applicant} ->
        notify_parent({:saved, applicant})

        socket =
          socket
          |> put_flash(:info, "Applicant #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, applicant))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{applicant: applicant}} = socket) do
    form =
      if applicant do
        AshPhoenix.Form.for_update(applicant, :update, as: "applicant")
      else
        AshPhoenix.Form.for_create(Exins.PolicySystem.Applicant, :create, as: "applicant")
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _applicant), do: ~p"/applicants"
  defp return_path("show", applicant), do: ~p"/applicants/#{applicant.id}"
end
