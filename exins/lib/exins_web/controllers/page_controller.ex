defmodule ExinsWeb.PageController do
  @moduledoc """
  The PageController is responsible for rendering the home page.
  """
  use ExinsWeb, :controller

  @doc """
  Renders the home page.

  ## Parameters
    - `conn`: The `Plug.Conn` struct.
    - `_params`: A map of parameters from the request.

  ## Returns
    - A rendered `Plug.Conn` struct.
  """
  def home(conn, _params) do
    render(conn, :home)
  end
end
