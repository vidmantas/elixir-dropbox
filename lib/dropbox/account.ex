defmodule Dropbox.Account do

  defstruct email: nil,
            referral_link: nil,
            display_name: nil,
            uid: nil,
            country: nil,
            team: %Dropbox.Account.Team{},
            quota_info: %Dropbox.Account.Quota{}

  @base_url "https://api.dropbox.com/1"

  #  Formerly account_info
  def get_info(client) do
    Dropbox.HTTP.get client, "#{@base_url}/account/info", __MODULE__
  end

  #  Formerly account_info!
  def get_info!(client) do
    case get_info client do
      {:ok, info} -> info
      {:error, reason} -> Dropbox.Error.raise_error reason
    end
  end

end