defmodule Dropbox.Auth do

  @base_url "https://api.dropbox.com/1"

  ### OAuth 2.0: optional, can be handled by third-party lib or manually ###

  def authorize_url(client, re_uri \\ nil, state \\ "") do
    _authorize_url(client, re_uri, state)
  end

  defp _authorize_url(client, nil, state) do
    query(client, state)
    |> url
  end

  defp _authorize_url(client, redirect_uri, state) do
    Map.put( query(client, state), :redirect_uri, redirect_uri )
    |> url
  end

  defp query(%{client_id: c_id}=client, state) do
    %{client_id: c_id, response_type: "code", state: state}
  end

  defp url(query) do
    "https://www.dropbox.com/1/oauth2/authorize?#{URI.encode_query query}"
  end

  def access_token(client, code) do
    case Dropbox.HTTP.post client, oauth2_authcode(code), nil, %{access_token: nil, uid: nil} do
      {:ok, token} -> {:ok, token.access_token, token.uid}
      e -> e
    end
  end

  defp oauth2_authcode(code) do
    "#{@base_url}/oauth2/token?grant_type=authorization_code&code=#{URI.encode(code)}"
  end

  def disable_access_token(client) do
    case Dropbox.HTTP.post client, "#{@base_url}/disable_access_token" do
      {:ok, _} -> :ok
      e -> e
    end
  end

  def fetch_account({:ok, access_token, uid}, client) do
    client = %{client | access_token: access_token}
    Dropbox.get_info(client)
    |> account_ok(client)
  end

  defp account_ok({:ok, acc}, client) do
    {:ok, acc, client}
  end

  defp account_ok({:error, _}, client) do
    {:bad, client}
  end

  defp account_ok(_, client) do
    {:error, client}
  end
  
end