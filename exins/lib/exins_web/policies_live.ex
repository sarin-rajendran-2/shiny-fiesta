defmodule ExInsWeb.PoliciesLive do
  use ExInsWeb, :live_view
  alias ExIns.PolicySystem.Policy
  alias ExIns.PolicySystem.PolicyDocument

  def render(assigns) do
    ~H"""
    <.live_title>
      <%= if assigns |> Map.has_key?(:page_title), do: "Policy - " <> assigns[:page_title], else: "New Quote" %>
    </.live_title>
    <h2 style="margin-bottom: 12px; border-bottom: 1px solid black">Policies</h2>
    <div>
      <%= for policy <- @policies do %>
        <% doc = policy.doc %>
        <div style="background: whitesmoke; border-radius: 8px; display:grid; grid-template-columns: 1fr 1fr; row-gap: 4px; margin-bottom: 8px; padding: 4px">
          <div style="font-weight: bolder"><%= doc.policy_number %></div>
          <div><%= doc.status %></div>
          <div>Policy Id: <%= policy.id %></div>
          <div>Policy Document Id: <%= doc.id %></div>
          <div><%= doc.inception_date %></div>
          <div><%= doc.expiry_date %></div>
          <div><%= policy.created_at %></div>
          <div><%= policy.updated_at %></div>
          <.button style="grid-column: span 2; justify-self: left" type="button" phx-click="delete_policy" phx-value-policy-id={policy.id}>delete</.button>
        </div>
      <% end %>
    </div>
    <h2 style="margin-top: 24px; border-bottom: 1px solid black">Create Policy</h2>
    <.form for={@create_form} phx-submit="create_policy" style="display: grid; grid-template-columns: 1fr 1fr; row-gap: 4px; column-gap: 12px">
        <.input label="Policy Number" type="text" field={@create_form[:policy_number]} placeholder="input policy number" />
        <.input label="Status" type="select" field={@create_form[:status]} placeholder="select status" options={[:quote, :in_force, :cancelled]} />
        <.input label="Inception Date" type="date" field={@create_form[:inception_date]} placeholder="Inception date" />
        <.input label="Expiry Date" type="date" field={@create_form[:expiry_date]} placeholder="Expiry date" />
        <.button type="submit" style="justify-self: left">create</.button>
    </.form>
    <h2 style="margin-top: 24px; border-bottom: 1px solid black">Update Policy</h2>
    <.form for={@update_form} phx-submit="update_policy" style="display: grid; grid-template-columns: 1fr 1fr; row-gap: 4px; column-gap: 12px">
      <.input type="select" field={@update_form[:id]} options={@policy_selector} phx-change="select_policy" phx-debounce="200" />
      <nobr />
      <.input label="Policy Number" type="text" field={@update_form[:policy_number]} placeholder="input policy number" />
      <.input label="Status" type="select" field={@update_form[:status]} placeholder="select status" options={[:quote, :in_force, :cancelled]} />
      <.input label="Inception Date" type="date" field={@update_form[:inception_date]} placeholder="Inception date" />
      <.input label="Expiry Date" type="date" field={@update_form[:expiry_date]} placeholder="Expiry date" />
      <nbsp/>
      <.button type="submit" style="grid-column: 1 / -1; justify-self: left">Update</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    policies = Policy.read_all!()
    policy_docs = for policy <- policies do
      policy.doc
    end

    selected_policy = List.first(policy_docs, %PolicyDocument{})
    socket =
      assign(socket,
        policies: policies,
        policy_selector: policy_selector(policies),
        # the `to_form/1` calls below are for liveview 0.18.12+. For earlier versions, remove those calls
        create_form: AshPhoenix.Form.for_create(PolicyDocument, :create) |> to_form(),
        update_form: AshPhoenix.Form.for_update(selected_policy, :update) |> to_form()
      )

    {:ok, socket}
  end

  def handle_event("delete_policy", %{"policy-id" => policy_id}, socket) do
    policy_id |> Policy.get_by_id!() |> Policy.destroy!()
    policies = Policy.read_all!()

    {:noreply, assign(socket, policies: policies, policy_selector: policy_selector(policies))}
  end

  def handle_event("create_policy", %{"form" => %{"policy_number" => policy_number, "status" => status, "inception_date" => inception_date, "expiry_date" => expiry_date}}, socket) do
    doc = PolicyDocument.create!(%{policy_number: policy_number, status: status, inception_date: inception_date, expiry_date: expiry_date})
    Policy.create(%{id: doc.id, doc: doc})
    policies = Policy.read_all!()

    {:noreply, assign(socket, policies: policies, policy_selector: policy_selector(policies))}
  end

  def handle_event("select_policy", %{"form" => %{"id" => id}}, socket) do
    selected_policy = id |> Policy.get_by_id!()

    update_form =
      AshPhoenix.Form.for_update(selected_policy.doc, :update)
      |> to_form()

    {:noreply, assign(socket, update_form: update_form)}
  end

  def handle_event("update_policy", %{"form" => form_params}, socket) do
    %{"id" => id, "policy_number" => policy_number, "status" => status, "inception_date" => inception_date, "expiry_date" => expiry_date} = form_params

    id |> Policy.get_by_id!() |> Policy.update!(%{doc: %{policy_number: policy_number, status: status, inception_date: inception_date, expiry_date: expiry_date}})
    policies = Policy.read_all!()

    {:noreply,
     assign(socket,
       policies: policies,
       policy_selector: policy_selector(policies)
     )}
  end

  defp policy_selector(policies) do
    for policy <- policies do
      { "#{policy.doc.policy_number} (#{policy.doc.status})", policy.id}
    end
  end
end
