defmodule ExinsWeb.PolicyLive.FormComponent do
  use ExinsWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage policy records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="policy-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <:actions>
          <.button phx-disable-with="Saving...">Save Policy</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"policy" => policy_params}, socket) do
    {:noreply, assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, policy_params))}
  end

  def handle_event("save", %{"policy" => policy_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: policy_params) do
      {:ok, policy} ->
        notify_parent({:saved, policy})

        socket =
          socket
          |> put_flash(:info, "Policy #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

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
        _policyDocForm =
          AshPhoenix.Form.for_create(Exins.PolicySystem.PolicyDocument, :create, as: "policyDocument", forms: [auto?: [type: :list]])
        policyForm =
          AshPhoenix.Form.for_create(Exins.PolicySystem.Policy, :create, as: "policy", forms: [type:  :single, ])
        policyForm
      end
    form |> IO.inspect
    assign(socket, form: to_form(form))
  end
end
