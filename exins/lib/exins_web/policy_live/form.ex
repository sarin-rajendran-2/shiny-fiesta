defmodule ExinsWeb.PolicyLive.Form do
  @moduledoc """
  This LiveView provides a form for creating and updating policy records.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage policy records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="policy-form"
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:applicant]} type="text" label="Applicant" /><.input
            field={@form[:effective_date]}
            type="date"
            label="Effective date"
          /><.input field={@form[:expiry_date]} type="date" label="Expiry date" /><.input
            field={@form[:line_of_business]}
            type="select"
            label="Line of business"
            options={
              Ash.Resource.Info.attribute(Exins.PolicySystem.Policy, :line_of_business).constraints[
                :one_of
              ]
            }
          />
          <.input
            field={@form[:status]}
            type="select"
            label="Status"
            options={
              Ash.Resource.Info.attribute(Exins.PolicySystem.Policy, :status).constraints[:one_of]
            }
          />
          <.input field={@form[:doc]} type="text" label="Doc" /><.input
            field={@form[:applicant_id]}
            type="text"
            label="Applicant"
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:effective_date]} type="date" label="Effective date" /><.input
            field={@form[:expiry_date]}
            type="date"
            label="Expiry date"
          /><.input
            field={@form[:line_of_business]}
            type="select"
            label="Line of business"
            options={
              Ash.Resource.Info.attribute(Exins.PolicySystem.Policy, :line_of_business).constraints[
                :one_of
              ]
            }
          />
          <.input
            field={@form[:status]}
            type="select"
            label="Status"
            options={
              Ash.Resource.Info.attribute(Exins.PolicySystem.Policy, :status).constraints[:one_of]
            }
          />
          <.input field={@form[:doc]} type="text" label="Doc" /><.input
            field={@form[:applicant_id]}
            type="text"
            label="Applicant"
          />
        <% end %>

        <.button phx-disable-with="Saving..." variant="primary">Save Policy</.button>
        <.button navigate={return_path(@return_to, @policy)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    policy =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(Exins.PolicySystem.Policy, id)
      end

    action = if is_nil(policy), do: "New", else: "Edit"
    page_title = action <> " " <> "Policy"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(policy: policy)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @doc """
  Handles the form validation event.
  """
  @impl true
  def handle_event("validate", %{"policy" => policy_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, policy_params))}
  end

  @doc """
  Handles the form submission event.
  """
  @impl true
  def handle_event("save", %{"policy" => policy_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: policy_params) do
      {:ok, policy} ->
        notify_parent({:saved, policy})

        socket =
          socket
          |> put_flash(:info, "Policy #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, policy))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{policy: policy}} = socket) do
    form =
      if policy do
        AshPhoenix.Form.for_update(policy, :update, as: "policy")
      else
        AshPhoenix.Form.for_create(Exins.PolicySystem.Policy, :create, as: "policy")
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _policy), do: ~p"/policies"
  defp return_path("show", policy), do: ~p"/policies/#{policy.id}"
end
