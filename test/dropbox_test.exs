defmodule DropboxTest do
  use ExUnit.Case
  alias  Dropbox.Setup
  import Dropbox.TestHelper, only: [access_key: 0, client: 0, write_file: 1]

  setup_all do
    Dropbox.HTTP.start
    try do
      Dropbox.Setup.connect
      |> IO.inspect
    rescue
      e ->
        IO.puts "
  Error: #{inspect e}

  You need to set your App Tokens environment variable for credential storage:
  See test/test_helper.exs file: DropBox.TestHelper.client/0
  Cannot read in ./.dropbox-access-token"
        :bad
    end
  end


  test "get account info", ctx do
    account = Dropbox.Account.get_info! ctx[:client]

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

  defp random_name do
    "test-" <> :base64.encode(:crypto.rand_bytes(8)) |> String.replace(~r/[^a-zA-Z]/, "")
  end
end
