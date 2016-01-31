defmodule Dropbox.File do
  import Dropbox.Error
  import Dropbox.HTTP, only: [wait_response: 2]

  @base_content_url "https://api-content.dropbox.com/1"

  def download(client, path, rev \\ nil) do
    Dropbox.HTTP.get client, "#{@base_content_url}/files/#{client.root}#{normalize_path path}#{if rev do "?rev=" <> rev end}", Dropbox.Metadata
  end

  def download!(client, path, rev \\ nil) do
    case download(client, path, rev) do
      {:ok, _meta, contents} -> contents
      {:error, reason} -> 
            raise_error(reason)
            |> IO.inspect
    end
  end

  def download_file(client, path, local_path, rev \\ nil, keep_mtime \\ true) do
    parent = self
    pid = spawn fn -> wait_response parent, %{file: local_path, meta: nil, error: nil} end

    case Dropbox.HTTP.get client, "#{@base_content_url}/files/#{client.root}#{normalize_path path}#{if rev do "?rev=" <> rev end}", Dropbox.Metadata, pid do
      {:ok, _ref} ->
        receive do
          {_ref, :done, meta} ->
            if keep_mtime do
              case File.stat local_path, [{:time, :universal}] do
                {:ok, stat} ->
                  stat = %{stat | mtime: Dropbox.Util.parse_date meta.client_mtime}
                  File.write_stat local_path, stat, [{:time, :universal}]
                _ ->
              end
            end
            {:ok, meta}
          {_ref, :error, reason} -> {:error, reason}
        end
      e -> e
    end
  end

  def entire_file!(client, path, local_path, rev \\ nil, keep_mtime \\ true) do
    case download_file client, path, local_path, rev, keep_mtime do
      {:ok, meta} -> meta
      {:error, reason} -> raise_error reason
    end
  end

  defp normalize_path(path) do
    if String.starts_with? path, "/" do
      path
    else
      "/#{path}"
    end
  end

end