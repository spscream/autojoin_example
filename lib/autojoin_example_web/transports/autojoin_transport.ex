defmodule AutojoinExampleWeb.Transports.AutojoinTransport do
  @behaviour Phoenix.Socket.Transport

  import Phoenix.Socket
  require Logger

  defmodule SocketParams do
    use Construct do
      field :features, :boolean, default: true
      field :auto_join, :boolean, default: true
    end
  end

  def child_spec(opts) do
    websocket_opts = Keyword.get(opts, :websocket, [])
    socket_handler = Keyword.get(websocket_opts, :socket)

    socket_handler.child_spec(opts)
  end

  def connect(%{options: opts} = map) do
    socket_handler = Keyword.get(opts, :socket)

    with {:ok, socket_params} <- SocketParams.make(map.params),
         {:ok, {transport_state, socket}} <- socket_handler.connect(map)
    do
      socket =
        socket
        |> assign(:features, socket_params.features)
        |> assign(:auto_join, socket_params.auto_join)

      {:ok, {transport_state, socket}}
    else
      error ->
        error
    end
  end

  def init({_state, socket} = state) do
    if socket.assigns.features do
      send self(), :features
    end

    with {:ok, {_, socket} = initial_state} <- socket.handler.init(state)
    do
      if socket.assigns.auto_join do
        autojoin_topics(
          socket.handler.autojoin_topics(socket),
          initial_state
        )
      else
        {:ok, initial_state}
      end
    end
  end

  def handle_in({payload, opts}, state) do
    socket.handler.handle_in({payload, opts}, state)
  end

  def handle_info(:features, {_transport_state, socket} = state) do
    if Map.get(socket.assigns, :features) do
      push_message(state, %Phoenix.Socket.Message{
          topic: "phoenix", event: "features", payload: %{features: AutojoinExample.features()}
      })
    else
      {:ok, state}
    end
  end

  def handle_info(request, state) do
    socket.handler.handle_info(request, state)
  end

  def terminate(reason, {_transport_state, socket} = state) do
    socket.handler.terminate(reason, state)
  end

  # Private API

  defp push_message({_transport_state, socket} = state, message) do
      {:socket_push, opcode, payload} =
        socket.serializer.encode!(message)
      {:push, {opcode, payload}, state}
  end

  defp autojoin_topics([topic|rest], state) do
    {:ok, new_state} = join_channel(topic, state)

    autojoin_topics(rest, new_state)
  end

  defp autojoin_topics([], state) do
    {:ok, state}
  end

  defp join_channel(topic, {_transport_state, socket} = state) do
    join_message = """
    {"event":"phx_join","payload":{},"ref":"autojoin","topic":"#{topic}"}
    """

    {:reply, :ok, _reply, new_state} = socket.handler.handle_in(
      {join_message, [opcode: :text]}, state
    )

    {:ok, new_state}
  end
end
