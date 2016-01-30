defmodule Dropbox.AuthTest do
  use ExUnit.Case
  import Dropbox.TestHelper, only: [access_key: 0, client: 0]
  
  # @access_key  System.get_env("DROPBOX_APP_ID")

  # def client do
  #   %Dropbox.Client{ 
  #       client_id: access_key,
  #       client_secret: System.get_env("DROPBOX_SECRET_KEY") }
  # end

  def read_file(creds_file) do
    if not File.exists? creds_file do
      _client_struct = client
    end
  end

  def setup_creds do
    try do 
      creds_file = Path.expand System.get_env "DB_CREDS"
      # if not File.exists? creds_file do
    rescue
      e ->
        IO.puts "
  Error: #{inspect e}
  You need to set the DB_CREDS environment variable for credential storage:
        DB_CREDS=~/.dropbox-test-credentials mix test"
        :bad
    end
  end
  
  test "#Ensure raise message is file not there." do
    assert setup_creds == :bad
  end

  test "#Generate Oauth access url Step." do 
    url = client
    |> Dropbox.Auth.authorize_url
    assert url == "https://www.dropbox.com/1/oauth2/authorize?client_id=#{access_key}&response_type=code&state=" 
  end

  test "Oauth access url - with redirect_url #string " do 
    url = client
    |> Dropbox.Auth.authorize_url("REDIRECT_URL")
    result = URI.parse(url).query
          |> URI.decode_query
    assert result |> Map.has_key?("redirect_uri")
  end

end