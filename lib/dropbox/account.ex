defmodule Dropbox.Account do
  defstruct email: nil,
            referral_link: nil,
            display_name: nil,
            uid: nil,
            country: nil,
            team: %Dropbox.Account.Team{},
            quota_info: %Dropbox.Account.Quota{}
end