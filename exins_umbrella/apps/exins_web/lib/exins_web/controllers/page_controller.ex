defmodule ExinsWeb.PageController do
  use ExinsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
