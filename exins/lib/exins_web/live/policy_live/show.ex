defmodule ExinsWeb.PolicyLive.Show do
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Policy <%= @policy.id %>
      <:subtitle>This is a policy record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/policies/#{@policy}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit policy</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Doc"><%= @policy.doc %></:item>
    </.list>

    <.back navigate={~p"/policies"}>Back to policies</.back>

    <.modal
      :if={@live_action == :edit}
      id="policy-modal"
      show
      on_cancel={JS.patch(~p"/policies/#{@policy}")}
    >
      <.live_component
        module={ExinsWeb.PolicyLive.FormComponent}
        id={@policy.id}
        title={@page_title}
        action={@live_action}
        policy={@policy}
        patch={~p"/policies/#{@policy}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:policy, Ash.get!(Exins.PolicySystem.Policy, id))}
  end

  defp page_title(:show), do: "Show Policy"
  defp page_title(:edit), do: "Edit Policy"
end
