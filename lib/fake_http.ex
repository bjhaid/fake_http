defmodule FakeHttp do
  def start(port \\ 2000) do
    lsock = connect(port)
    fake_http_pid = spawn(fn -> loop(lsock) end)
    kv_pid = spawn(fn ->
      :ets.new(:fake_http_cache, [:named_table, :duplicate_bag, :protected])
      kv
    end)
    Process.register(kv_pid, :kv)
    Process.register(fake_http_pid, :fake_http)
  end

  def stop() do
    try do
      send(:kv, :stop)
      exit(:fake_http)
    catch
      :exit, _ -> :stopped
    end
  end

  for method <- ["message", "header", "query_param"] do
    def unquote(String.to_atom(method <> "s"))() do
      unquote(method) |> String.to_atom |> fetch_value
    end

    def unquote(String.to_atom("last_" <> method))() do
      List.last(unquote(String.to_atom(method <> "s"))())
    end
  end

  defp fetch_value(value) do
    send(:kv, {self(), :fetch, value})
    receive do
      value -> value
    after
      100 -> []
    end
  end

  def url() do
    "http://localhost:" <> to_string(Process.get(:port))
  end

  defp connect(port) when(port < 63_000) do
    case :gen_tcp.listen(port, [:binary, {:packet, 0}, {:active, false}]) do
      {:ok, lsock} ->
        Process.put(:port, port)
        lsock
      {:error, :eaddrinuse} -> connect(port + 1)
    end
  end

  defp connect(_) do
    :no_port_available
  end

  defp do_recv(sock) do
    case :gen_tcp.recv(sock, 0, 5) do
      {:ok, packet} ->
        String.split(packet, "\r\n") |> process_request_type |> process_message |> process_headers
        :gen_tcp.send(sock, "HTTP/1.1 201 OK\r\nServer: FakeHttp\r\nFinished \r\n")
        :gen_tcp.close(sock)
      {:error, error} ->
        IO.puts(error)
    end
  end

  defp process_request_type([requestType | payload]) do
    [request_type, path_and_params, protocol] = String.split(requestType, " ")
    case String.split(path_and_params, "?") do
      [path] -> store({:path, path})
      [path, query_params] -> store({:path, path})
        store({:query_param, parse_query_params(query_params)})
    end
    store({:request_type, request_type})
    store({:protocol, protocol})
    payload
  end

  defp parse_query_params(query_params) do
    String.split(query_params, "&") |> Enum.map(fn(x) -> tokenize(x, "=") end)
  end

  defp process_message(payload) do
    [message|payload1] = :lists.reverse(payload)
    store {:message, message}
    :lists.reverse(payload1)
  end

  defp store(value) do
    send(:kv, {:put, value})
  end

  defp tokenize(string, delimeter) do
    [name, value] = String.split(string, delimeter)
    new_name = name |> String.downcase |> String.to_atom
    {new_name, value}
  end

  defp process_headers(payload) do
    headers = for x <- payload, Regex.match?(~r/\w+:\s\w+/, x), do: tokenize(x, ": ")
    store({:header, headers})
  end

  defp loop(lsock) do
    case :gen_tcp.accept(lsock) do
      {:ok, sock}  ->
        handler = spawn_link(fn -> do_recv(sock) end)
        :gen_tcp.controlling_process(sock, handler)
        loop(lsock)
      {:error, _} ->
        :gen_tcp.shutdown(lsock, :read_write)
        :ok
    end
  end

  defp kv() do
    receive do
      {:put, any} ->
        :ets.insert(:fake_http_cache, any)
        kv()
      {pid, :fetch, key} ->
        result = Enum.map(:ets.lookup(:fake_http_cache, key), fn({_key, message}) -> message end)
        send(pid, result)
        kv()
      :stop ->
        :ets.delete(:fake_http_cache)
        :stopped
        _ -> :unknown
    end
  end
end
