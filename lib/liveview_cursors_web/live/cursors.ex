defmodule LiveviewCursorsWeb.Cursors do
  import LiveviewCursorsWeb.Colors
  alias LiveviewCursorsWeb.Presence
  use LiveviewCursorsWeb, :live_view

  @cursorview "cursorview"
  def mount(_params, %{"user" => user}, socket) do
    Presence.track(self(), @cursorview, socket.id, %{
      socket_id: socket.id,
      x: 50,
      y: 50,
      msg: "",
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
      |> assign(:hearts, [])

    {:ok, updated}
  end

  # if no user name, redirect to root to generate one
  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    updatePresence(socket.id, %{x: x, y: y})
    {:noreply, socket}
  end

  def handle_event("send_message", %{"msg" => msg}, socket) do
    updatePresence(socket.id, %{msg: msg})
    {:noreply, socket}
  end

  def updatePresence(key, payload) do
    metas =
      Presence.get_by_key(@cursorview, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @cursorview, key, metas)
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    hearts =
      users
      |> Enum.group_by(&{round(&1.x / 5), round(&1.y / 5)})
      |> Enum.filter(fn {_, group} -> Enum.count(group) > 1 end)
      |> Enum.map(fn {coordinates, _} -> coordinates end)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)
      |> assign(hearts: hearts)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <section class="flex flex-col w-screen h-screen justify-center items-center text-center">
      <form
      id="msgform"
      phx-submit="send_message"
      class="rounded-xl bg-gradient-to-r to-pink-100 from-pink-50 p-8 drop-shadow-xl flex w-xs mx-auto space-x-3"
      >
        <input
          class="flex-1 appearance-none border border-transparent py-2 px-4 bg-white text-gray-600 placeholder-gray-400 shadow-md rounded-lg text-base focus:outline-none focus:ring-2 focus:ring-pink-600 focus:border-transparent"
          maxlength="30"
          aria-label="Your message"
          type="text"
          id="msg"
          name="msg"
          placeholder="Say something"
        />
        <input
          id="submit-msg"
          type="submit"
          class="flex-shrink-0 bg-pink-600 text-white text-base font-semibold py-2 px-4 rounded-lg shadow-md hover:bg-pink-700 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:ring-offset-2 focus:ring-offset-pink-200"
          value="Send"
        />
      </form>
      <ul class="list-none" id="cursors" phx-hook="TrackClientCursor">
        <%= for user <- @users do %>
          <% color = getHSL(user.name) %>
          <li style={"color: #{color}; left: #{user.x}%; top: #{user.y}%"} class="flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden">
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
                points="9.2,7.3 9.2,18.5 12.2,15.6 12.6,15.5 17.4,15.5" />
            </svg>
            <span style={"background-color: #{color};"} class="mt-1 ml-4 px-1 text-sm text-white w-fit">
              <%= user.name %>
            </span>
            <span style={"background-color: #{color};"} class="text-green-50 mt-1 py-0 px-1 text-sm text-left rounded-br-md opacity-80 fit-content">
              <%= user.msg %>
            </span>
          </li>
        <% end %>
      </ul>
      <%= for {x, y} <- @hearts do %>
        <svg
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          x="0px"
          y="0px"
          viewBox="0 0 512.001 512.001"
          xml:space="preserve"
          style={"left: calc(#{x * 5}% + 13px); top: calc(#{y * 5}% + 13px); enable-background: new 0 0 512.001 512.001"}
          class="flex flex-col absolute pointer-events-none whitespace-nowrap whitespace-nowrap overflow-hidden beat"
        >
          <path
            fill="#ec4899"
            d="M510.551,155.314c-8.628-61.937-58.264-112.739-120.03-122.518
          c-45.314-7.173-87.448,6.688-118.301,33.288c-9.434,8.133-22.999,8.136-32.433,0.001c-30.883-26.626-73.067-40.49-118.431-33.269
          C60.309,42.534,10.95,92.315,1.715,153.438c-6.906,45.7,7.526,88.164,34.834,118.939c4.485,5.055,203.403,201.599,203.403,201.599
          c9.565,9.5,25.009,9.473,34.541-0.059l197.115-197.538C500.944,245.745,517.108,202.389,510.551,155.314z"
          />
          <path
            fill="#ec4899"
            d="M87.169,265.844c-27.307-30.773-41.739-73.238-34.837-118.939
          c8.199-54.251,48.124-99.519,99.657-115.816c-9.97-0.46-20.234,0.072-30.635,1.727C60.307,42.534,10.951,92.316,1.713,153.438
          c-6.904,45.7,7.525,88.164,34.832,118.939c4.487,5.056,203.403,201.599,203.403,201.599c9.568,9.5,25.01,9.473,34.54-0.057
          l11.238-11.26C255.296,432.582,91.235,270.431,87.169,265.844z"
          />
        </svg>
      <% end %>
    </section>
    """
  end
end
