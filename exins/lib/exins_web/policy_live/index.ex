defmodule ExinsWeb.PolicyLive.Index do
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Policies
        <:actions>
          <.button variant="primary" navigate={~p"/policies/new"}>
            <.icon name="hero-plus" /> New Policy
          </.button>
        </:actions>
      </.header>

      <.table
        id="policies"
        rows={@streams.policies}
        row_click={fn {_id, policy} -> JS.navigate(~p"/policies/#{policy}") end}
      >
        <:col :let={{_id, policy}} label="Id">{policy.id}</:col>

        <:col :let={{_id, policy}} label="Effective date">{policy.effective_date}</:col>

        <:col :let={{_id, policy}} label="Expiry date">{policy.expiry_date}</:col>

        <:col :let={{_id, policy}} label="Line of business">{policy.line_of_business}</:col>

        <:col :let={{_id, policy}} label="Status">{policy.status}</:col>

        <:col :let={{_id, policy}} label="Doc">{policy.doc}</:col>

        <:col :let={{_id, policy}} label="Applicant">{policy.applicant_id}</:col>

        <:action :let={{_id, policy}}>
          <div class="sr-only">
            <.link navigate={~p"/policies/#{policy}"}>Show</.link>
          </div>

          <.link navigate={~p"/policies/#{policy}/edit"}>Edit</.link>
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
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Policies")
     |> stream(:policies, Ash.read!(Exins.PolicySystem.Policy))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    policy = Ash.get!(Exins.PolicySystem.Policy, id)
    Ash.destroy!(policy)

    {:noreply, stream_delete(socket, :policies, policy)}
  end
end
