defmodule Dropbox.HTTP do
  import Dropbox.Util
  
  def start do
    :hackney.start
  end

  def get(client, url, res_struct \\ nil, stream_pid \\ nil) do
    do_request client, :get, url, nil, res_struct, stream_pid
  end

  def post(client, url, body \\ nil, res_struct \\ nil) do
    do_request client, :post, url, body, res_struct
  end

  def put(client, url, body, res_struct \\ nil) do
    do_request client, :put, url, body, res_struct
  end

  defp do_request(client, method, url, body, res_struct, stream_pid \\ nil) do
    headers = fetch_headers( client, client.access_token)

    case body do
      {:json, json} ->
        headers = [{"Content-Type", "application/json"} | headers]
        body = Jazz.encode! json
      {:file, _path} -> true
      _ -> body = []
    end

    options = set_options(stream_pid)

    case :hackney.request method, url, headers, body, options do
      {:ok, code, headers, body_ref} ->
        {:ok, body} = :hackney.body body_ref
        download = false
        
        case Enum.find(headers, fn({k,_}) -> k == "x-dropbox-metadata" end) do
          {_, meta} ->
            download = true
            json = atomize_map Dropbox.Metadata, Jazz.decode!(meta)
          nil ->
            json = Jazz.decode!(body)
        end

        cond do
          code in 200..299 ->
            if download do
              {:ok, atomize_map(res_struct, json), body}
            else
              {:ok, atomize_map(res_struct, json)}
            end
          code in 400..599 ->
            {:error, {{:http_status, code}, json["error"]}}
          true ->
            {:error, json}
        end # cond
      e -> e
    end # case:hackney
  end

  defp opts, do: [{:pool, :default}]
  
  defp set_options(nil), do: opts
  defp set_options(pid) when is_pid(pid) do
    [:async, {:stream_to, pid} | opts]
  end
  
  # internal - do_request
  defp fetch_headers(client, token) when is_nil(token) do
    [{"Authorization", "Basic #{Base.encode64 client.client_id <> ":" <> client.client_secret}"}]
  end
  
  # internal - do_request
  defp fetch_headers(client, _token) do
    [{"Authorization", "Bearer #{client.access_token}"}]
  end

end
