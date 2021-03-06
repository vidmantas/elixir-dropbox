defmodule Dropbox do
  @moduledoc """
  Provides an interface to the Dropbox Core API.
  """
  import Dropbox.Error
  import Dropbox.HTTP, only: [wait_response: 2]

  @base_url "https://api.dropbox.com/1"
  @base_content_url "https://api-content.dropbox.com/1"

  def start do
    Dropbox.HTTP.start
  end

  def start(_type, _args) do
    start
    {:ok, self}
  end

  ### Files and metadata ###
  # For backward compatibility
  def download(client, path, rev \\ nil) do
    Dropbox.File.download(client, path, rev)
  end
  # For backward compatibility
  def download!(client, path, rev \\ nil) do
    Dropbox.File.download!(client, path, rev)
  end

  def download_file(client, path, local_path, rev \\ nil, keep_mtime \\ true) do
    Dropbox.File.download_file(client, path, local_path, rev, keep_mtime)
  end

  def download_file!(client, path, local_path, rev \\ nil, keep_mtime \\ true) do
    Dropbox.File.entire_file!(client, path, local_path, rev, keep_mtime)
  end

  def upload_file(client, local_path, remote_path, overwrite \\ true, parent_rev \\ nil) do
    query = %{
      overwrite: overwrite
    }

    if parent_rev do
      query = Map.put query, :parent_rev, parent_rev
    end

    Dropbox.HTTP.put client, "#{@base_content_url}/files_put/#{client.root}#{normalize_path remote_path}", {:file, local_path}, Dropbox.Metadata
  end

  def upload_file!(client, local_path, remote_path, overwrite \\ true, parent_rev \\ nil) do
    case upload_file client, local_path, remote_path do
      {:ok, meta} -> meta
      {:error, reason} -> raise_error reason
    end
  end

  def metadata(client, path, options \\ []) do
    case Dropbox.HTTP.get client, "#{@base_url}/metadata/#{client.root}#{normalize_path path}", Dropbox.Metadata do
      {:ok, meta} ->
        {:ok, Map.put(meta, :contents, Enum.map(meta.contents, fn(x) -> Dropbox.Util.atomize_map Dropbox.Metadata, x end))}
      e -> e
    end
  end

  def metadata!(client, path, options \\ []) do
    case metadata client, path, options do
      {:ok, meta} -> meta
      {:error, reason} -> raise_error reason
    end
  end

  def delta(client, cursor \\ nil, path_prefix \\ nil, media \\ false), do: nil

  def wait_for_change(client, cursor, timeout \\ 30), do: nil

  def revisions(client, path, limit \\ 10) do
    Dropbox.HTTP.get client, "#{@base_url}/revisions/#{client.root}#{normalize_path path}?rev_limit=#{limit}", Dropbox.Metadata
  end

  def revisions!(client, path, limit \\ 10) do
    case revisions client, path, limit do
      {:ok, revs} -> revs
      {:error, reason} -> raise_error reason
    end
  end

  def restore(client, path, rev) do
  end

  def search(client, path, query, limit \\ 1000, deleted \\ false) do
    query = %{
      query: query,
      file_limit: limit,
      include_deleted: deleted
    }

    Dropbox.HTTP.get client, "#{@base_url}/search/#{client.root}#{normalize_path path}?#{URI.encode_query query}", Dropbox.Metadata
  end

  def search!(client, path, query, limit \\ 1000, deleted \\ false) do
    case search client, path, query, limit, deleted do
      {:ok, results} -> results
      {:error, reason} -> raise_error reason
    end
  end

  def share_url(client, path, short \\ true) do
    case Dropbox.HTTP.post client, "#{@base_url}/shares/#{client.root}#{normalize_path path}?short_url=#{short}", nil, %{url: nil, expires: nil} do
      {:ok, %{url: url, expires: expires}} -> {:ok, url, expires}
      e -> e
    end
  end

  def share_url!(client, path, short \\ true) do
    case share_url client, path, short do
      {:ok, %{url: url, expires: _expires}} -> url
      {:error, reason} -> raise_error reason
    end
  end

  def media_url(client, path) do
    case Dropbox.HTTP.post client, "#{@base_url}/media/#{client.root}#{normalize_path path}", nil, %{url: nil, expires: nil} do
      {:ok, %{url: url, expires: expires}} -> {:ok, url, expires}
      e -> e
    end
  end

  def media_url!(client, path) do
    case media_url client, path do
      {:ok, %{url: url, expires: _expires}} -> url
      {:error, reason} -> raise_error reason
    end
  end

  def copy_ref(client, path) do
    case Dropbox.HTTP.get client, "#{@base_url}/copy_ref/#{client.root}#{normalize_path path}", %{copy_ref: nil, expires: nil} do
      {:ok, %{copy_ref: copy_ref, expires: expires}} -> {:ok, copy_ref, expires}
      e -> e
    end
  end

  def copy_ref!(client, path) do
    case copy_ref client, path do
      {:ok, copy_ref, _expires} -> copy_ref
      {:error, reason} -> raise_error reason
    end
  end

  def thumbnail(client, path, size \\ :s, format \\ :jpeg) do
    Dropbox.HTTP.get client, "#{@base_content_url}/thumbnails/#{client.root}#{normalize_path path}?format=#{format}&size=#{size}"
  end

  def thumbnail!(client, path, size \\ :s, format \\ :jpeg) do
    case thumbnail client, path, size, format do
      {:ok, _meta, thumb} -> thumb
      {:error, reason} -> raise_error reason
    end
  end

  def upload_chunk(client, upload_id, offset, data) do
  end

  def commit_chunked_upload(client, upload_id, path, overwrite \\ true, parent_rev \\ nil) do
  end

  ### File operations ###

  def copy(client, from_path, to_path) do
    query = %{
      root: client.root,
      from_path: from_path,
      to_path: to_path
    }

    Dropbox.HTTP.post client, "#{@base_url}/fileops/copy?#{URI.encode_query query}"
  end

  def copy!(client, from_path, to_path) do
    case copy client, from_path, to_path do
      {:ok, _meta} -> true
      {:error, reason} -> raise_error reason
    end
  end

  def copy_from_ref(client, from_copy_ref, to_path) do
    query = %{
      root: client.root,
      from_copy_ref: from_copy_ref,
      to_path: to_path
    }

    Dropbox.HTTP.post client, "#{@base_url}/fileops/copy?#{URI.encode_query query}", Dropbox.Metadata
  end

  def copy_from_ref!(client, from_copy_ref, to_path) do
    case copy_from_ref client, from_copy_ref, to_path do
      {:ok, _} -> true
      {:error, reason} -> raise_error reason
    end
  end

  def mkdir!(client, path) do
    query = %{
      root: client.root,
      path: path
    }

    case Dropbox.HTTP.post client, "#{@base_url}/fileops/create_folder?#{URI.encode_query query}", Dropbox.Metadata do
      {:ok, _meta} -> true
      _ -> false
    end
  end

  def delete(client, path) do
    query = %{
      root: client.root,
      path: path
    }

    Dropbox.HTTP.post client, "#{@base_url}/fileops/delete?#{URI.encode_query query}"
  end

  def delete!(client, path) do
    case delete client, path do
      {:ok, _} -> true
      {:error, reason} -> raise_error reason
    end
  end

  def move(client, from_path, to_path) do
    query = %{
      root: client.root,
      from_path: from_path,
      to_path: to_path
    }

    Dropbox.HTTP.post client, "#{@base_url}/fileops/move?#{URI.encode_query query}"
  end

  def move!(client, from_path, to_path) do
    case move client, from_path, to_path do
      {:ok, _} -> true
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
