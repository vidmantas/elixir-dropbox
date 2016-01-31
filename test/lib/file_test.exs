defmodule Dropbox.FileTest do
  use ExUnit.Case
  import Dropbox.TestHelper, only: [access_key: 0, client: 0, random_name: 0]

  setup do 
    Dropbox.Setup.connect
  end

  test "Dropbox.File.download # download entire_file!", ctx do
    filename = random_name

    meta = Dropbox.upload_file! ctx[:client], "README.md", filename
    assert meta.path == "/#{filename}"
    assert File.read!("README.md") == Dropbox.File.download!(ctx[:client], "/#{filename}")

    tmp_file = Path.join(System.tmp_dir, filename)
    |> IO.inspect

    # Dropbox.download_file!
    xfile = Dropbox.File.entire_file!(ctx[:client], "#{filename}", tmp_file)
    assert  xfile == meta
    File.rm! tmp_file
    assert Dropbox.delete!(ctx[:client], filename) == true
  end

end