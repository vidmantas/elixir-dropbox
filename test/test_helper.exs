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
end
