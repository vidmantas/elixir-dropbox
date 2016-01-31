ExUnit.start

defmodule Dropbox.TestHelper do
  
  @access_key  System.get_env("DROPBOX_APP_ID")

  def client do
    %Dropbox.Client{ 
        client_id: @access_key,
        client_secret: System.get_env("DROPBOX_SECRET_KEY") }
  end

  def access_key do
    @access_key
  end

  def write_file(nil), do: :fail
  def write_file(access_token) when is_binary(access_token) do
      File.write! ".dropbox-access-token" , "#{access_token}"
  end

  def random_name do
    "test-" <> :base64.encode(:crypto.rand_bytes(8)) |> String.replace(~r/[^a-zA-Z]/, "")
  end

end

defmodule Dropbox.Setup do
  import Dropbox.TestHelper

  def connect do
      creds = Path.expand "./.dropbox-access-token"
      if not File.exists? creds do
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
  end

  def get_client(client, path) do
    file = File.open! path
    access_token = String.strip IO.read file, :line
    File.close file
    %{client | access_token: access_token, root: :dropbox }
  end
end
