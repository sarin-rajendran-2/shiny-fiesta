defmodule ExinsWeb.PolicyLive.Show do
  @moduledoc """
  This LiveView displays the details of a single policy.
  """
  use ExinsWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Policy {@policy.id}
        <:subtitle>This is a policy record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/policies"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/policies/#{@policy}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Policy
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@policy.id}</:item>

        <:item title="Effective date">{@policy.effective_date}</:item>

        <:item title="Expiry date">{@policy.expiry_date}</:item>

        <:item title="Line of business">{@policy.line_of_business}</:item>

        <:item title="Status">{@policy.status}</:item>

        <:item title="Doc">{@policy.doc}</:item>

        <:item title="Applicant">{@policy.applicant_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Policy")
     |> assign(:policy, Ash.get!(Exins.PolicySystem.Policy, id))}
  end
end
