defmodule DropboxTest do
  use ExUnit.Case
  import Dropbox.TestHelper, only: [access_key: 0, client: 0, write_file: 1]

  setup_all do
    Dropbox.HTTP.start
    try do
      creds_file = Path.expand "./.dropbox-access-token"
      
      if not File.exists? creds_file do
        url = client
        |> Dropbox.Auth.authorize_url
        IO.puts "To obtain a code, visit: #{url}"
        IO.write "Enter code: "
        code = String.strip IO.read :line
       
        result = Dropbox.Auth.access_token(client, code)
        |> Dropbox.Auth.fetch_account(client)

        access_token = case result do
          {:ok, acc, client} -> client.access_token
          _ -> nil 
        end
        write_file(access_token)
        |> IO.inspect
      end

      data = get_client(client, ".dropbox-access-token")
      {:ok, [client: data]}
    rescue
      e ->
        IO.puts "
  Error: #{inspect e}

  You need to set the DB_CREDS environment variable for credential storage:

        DB_CREDS=~/.dropbox-test-credentials mix test"
        :bad
    end
  end


  test "get account info", ctx do
    account = Dropbox.account_info! ctx[:client]

    assert account.email != nil
    assert account.quota_info.quota > 0
  end

  test "get root folder contents", ctx do
    meta = Dropbox.metadata! ctx[:client], "/"

    assert meta.is_dir == true
    assert Enum.count(meta.contents) > 0
  end

  test "directory operations", ctx do
    dirname = random_name

    assert Dropbox.mkdir!(ctx[:client], dirname) == true
    assert Dropbox.metadata!(ctx[:client], dirname).is_dir == true
    assert Dropbox.delete!(ctx[:client], dirname) == true
  end

  test "upload and download a file", ctx do
    filename = random_name

    meta = Dropbox.upload_file! ctx[:client], "README.md", filename
    assert meta.path == "/#{filename}"
    assert File.read!("README.md") == Dropbox.download!(ctx[:client], "/#{filename}")

    tmp_file = Path.join System.tmp_dir, filename
    assert Dropbox.download_file!(ctx[:client], "/#{filename}", tmp_file) == meta
    File.rm! tmp_file
    assert Dropbox.delete!(ctx[:client], filename) == true
  end

  defp get_client(client, path) do
    file = File.open! path
    access_token = String.strip IO.read file, :line
    File.close file
    %{client | access_token: access_token, root: :dropbox }
                    
  end

  defp random_name do
    "test-" <> :base64.encode(:crypto.rand_bytes(8)) |> String.replace(~r/[^a-zA-Z]/, "")
  end
end
