defmodule LiveviewCursorsWeb.PageController do
  use LiveviewCursorsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
