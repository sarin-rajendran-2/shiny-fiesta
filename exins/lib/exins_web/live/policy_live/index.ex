defmodule ExinsWeb.PolicyLive.Index do
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Policies
      <:actions>
        <.link patch={~p"/policies/new"}>
          <.button>New Policy</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="policies"
      rows={@streams.policies}
      row_click={fn {_id, policy} -> JS.navigate(~p"/policies/#{policy}") end}
    >
      <:col :let={{_id, policy}} label="Policy Number"><%= policy.doc.policy_number %></:col>
      <:col :let={{_id, policy}} label="Status"><%= policy.doc.status %></:col>
      <:col :let={{id, _policy}} label="Policy Id"><%= id %></:col>
      <:col :let={{_id, policy}} label="Document Id"><%= policy.doc.id %></:col>
      <:col :let={{_id, policy}} label="Inception Date"><%= policy.doc.inception_date %></:col>
      <:col :let={{_id, policy}} label="Expiry Date"><%= policy.doc.expiry_date %></:col>
      <:col :let={{_id, policy}} label="Created At"><%= policy.doc.created_at %></:col>
      <:col :let={{_id, policy}} label="Updated At"><%= policy.doc.updated_at %></:col>

      <:action :let={{_id, policy}}>
        <div class="sr-only">
          <.link navigate={~p"/policies/#{policy}"}>Show</.link>
        </div>

        <.link patch={~p"/policies/#{policy}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, policy}}>
        <.link
          phx-click={JS.push("delete", value: %{id: policy.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="policy-modal"
      show
      on_cancel={JS.patch(~p"/policies")}
    >
      <.live_component
        module={ExinsWeb.PolicyLive.FormComponent}
        id={(@policy && @policy.id) || :new}
        title={@page_title}
        action={@live_action}
        policy={@policy}
        patch={~p"/policies"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :policies, Ash.read!(Exins.PolicySystem.Policy))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Policy")
    |> assign(:policy, Ash.get!(Exins.PolicySystem.Policy, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Policy")
    |> assign(:policy, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Policies")
    |> assign(:policy, nil)
  end

  @impl true
  def handle_info({ExinsWeb.PolicyLive.FormComponent, {:saved, policy}}, socket) do
    {:noreply, stream_insert(socket, :policies, policy)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    policy = Ash.get!(Exins.PolicySystem.Policy, id)
    Ash.destroy!(policy)

    {:noreply, stream_delete(socket, :policies, policy)}
  end
end
