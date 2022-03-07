defmodule LiveviewCursorsWeb.Cursors do
  alias LiveviewCursorsWeb.Presence
  use LiveviewCursorsWeb, :live_view

  @cursorview "cursorview"
  def mount(_params, %{"user" => user}, socket) do
    Presence.track(self(), @cursorview, socket.id, %{
      socket_id: socket.id,
      x: 50,
      y: 50,
      name: user
    })

    LiveviewCursorsWeb.Endpoint.subscribe(@cursorview)

    initial_users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(:users, initial_users)
      |> assign(:socket_id, socket.id)

    {:ok, updated}
  end

  # if no user name, redirect to root to generate one
  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    key = socket.id
    payload = %{x: x, y: y}

    metas =
      Presence.get_by_key(@cursorview, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @cursorview, key, metas)

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <ul class="list-none" id="cursors" phx-hook="TrackClientCursor">
      <%= for user <- @users do %>
        <li style={"color: deeppink; left: #{user.x}%; top: #{user.y}%"} class="flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden">
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
          <span style={"background-color: deeppink;"} class="mt-1 ml-4 px-1 text-sm text-white"><%= user.name %></span>
        </li>
      <% end %>
    </ul>
    """
  end
end
