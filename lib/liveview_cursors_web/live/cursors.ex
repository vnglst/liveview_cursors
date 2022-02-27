defmodule LiveviewCursorsWeb.Cursors do
  use LiveviewCursorsWeb, :live_view

  def mount(_params, _session, socket) do
    updated =
      socket
      |> assign(:x, 50)
      |> assign(:y, 50)

    {:ok, updated}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    updated =
      socket
      |> assign(:x, x)
      |> assign(:y, y)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <ul class="list-none" id="cursors" phx-hook="TrackClientCursor">
      <li style={"color: deeppink; left: #{@x}%; top: #{@y}%"} class="absolute">
        <svg
        version="1.1"
        width="25px"
        height="25px"
        xmlns="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        viewBox="0 0 21 21">
          <polygon
          fill="black"
          points="8.2,20.9 8.2,4.9 19.8,16.5 13,16.5 12.6,16.6" />
          <polygon
          fill="currentColor"
          points="9.2,7.3 9.2,18.5 12.2,15.6 12.6,15.5 17.4,15.5"
          />
        </svg>
      </li>
    </ul>
    """
  end
end
