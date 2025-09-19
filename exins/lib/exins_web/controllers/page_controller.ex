defmodule ExinsWeb.PageController do
  use ExinsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
