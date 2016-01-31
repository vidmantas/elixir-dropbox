defmodule Dropbox.Account do

  defstruct email: nil,
            referral_link: nil,
            display_name: nil,
            uid: nil,
            country: nil,
            team: %Dropbox.Account.Team{},
            quota_info: %Dropbox.Account.Quota{}

  @base_url "https://api.dropbox.com/1"

  def account_info(client) do
    Dropbox.HTTP.get client, "#{@base_url}/account/info", Dropbox.Account
  end

  def account_info!(client) do
    case account_info client do
      {:ok, info} -> info
      {:error, reason} -> Dropbox.Error.raise_error reason
    end
  end

end