defmodule ExInsWeb.PoliciesLive do
  use ExInsWeb, :live_view
  alias ExIns.PolicySystem.Policy

  def render(assigns) do
    ~H"""
    <h2 style="margin-bottom: 12px; border-bottom: 1px solid black">Policies</h2>
    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr 1fr; row-gap: 4px" >
      <%= for policy <- @policies do %>
        <div><%= policy.policy_number %></div>
        <div><%= policy.status %></div>
        <div><%= if Map.get(policy, :content), do: policy.content, else: "" %></div>
        <.button type="button" phx-click="delete_policy" phx-value-policy-id={policy.id}>delete</.button>
      <% end %>
    </div>
    <h2 style="margin-top: 24px; border-bottom: 1px solid black">Create Policy</h2>
    <.form :let={f} for={@create_form} phx-submit="create_policy" style="display: grid; grid-template-columns: 1fr 1fr; row-gap: 4px; column-gap: 12px">
        <.input label="Policy Number" type="text" field={f[:policy_number]} placeholder="input policy number" />
        <.input label="Status" type="select" field={f[:status]} placeholder="select status" options={[:quote, :in_force, :cancelled]} />
        <.button type="submit" style="justify-self: left">create</.button>
    </.form>
    <h2 style="margin-top: 24px; border-bottom: 1px solid black">Update Policy</h2>
    <.form :let={f} for={@update_form} phx-submit="update_policy" style="display: grid; grid-template-columns: 1fr 1fr; row-gap: 4px; column-gap: 12px">
      <.input type="select" field={f[:id]} options={@policy_selector} phx-change="select_policy" />
      <nbsp/>
      <.input label="Policy Number" type="text" field={f[:policy_number]} placeholder="input policy number" />
      <.input label="Status" type="select" field={f[:status]} placeholder="select status" options={[:quote, :in_force, :cancelled]} />
      <.button type="submit" style="grid-column: 1 / -1; justify-self: left">Update</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    policies = Policy.read_all!()
    selected_policy = List.last(policies, %Policy{})

    socket =
      assign(socket,
        policies: policies,
        policy_selector: policy_selector(policies),
        # the `to_form/1` calls below are for liveview 0.18.12+. For earlier versions, remove those calls
        create_form: AshPhoenix.Form.for_create(Policy, :create) |> to_form(),
        update_form: AshPhoenix.Form.for_update(selected_policy, :update) |> to_form()
      )

    {:ok, socket}
  end

  def handle_event("delete_policy", %{"policy-id" => policy_id}, socket) do
    policy_id |> Policy.get_by_id!() |> Policy.destroy!()
    policies = Policy.read_all!()

    {:noreply, assign(socket, policies: policies, policy_selector: policy_selector(policies))}
  end

  def handle_event("create_policy", %{"form" => %{"policy_number" => policy_number, "status" => status}}, socket) do
    Policy.create(%{policy_number: policy_number, status: status})
    policies = Policy.read_all!()

    {:noreply, assign(socket, policies: policies, policy_selector: policy_selector(policies))}
  end

  def handle_event("select_policy", %{"form" => %{"id" => id}}, socket) do
    selected_policy = id |> Policy.get_by_id!()

    update_form =
      AshPhoenix.Form.for_update(selected_policy, :update)
      |> to_form()

    {:noreply, assign(socket, update_form: update_form)}
  end

  def handle_event("update_policy", %{"form" => form_params}, socket) do
    %{"id" => id, "policy_number" => policy_number} = form_params

    selected_policy = id |> Policy.get_by_id!() |> Policy.update!(%{policy_number: policy_number})
    policies = Policy.read_all!()

    update_form =
      AshPhoenix.Form.for_update(selected_policy, :update)
      |> to_form()

    {:noreply,
     assign(socket,
       policies: policies,
       policy_selector: policy_selector(policies),
       update_form: update_form
     )}
  end

  defp policy_selector(policies) do
    for policy <- policies do
      {policy.policy_number, policy.id}
    end
  end
end
