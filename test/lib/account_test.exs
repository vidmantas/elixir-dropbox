defmodule Dropbox.AccountTest do
  use ExUnit.Case
  import Dropbox.TestHelper, only: [access_key: 0, client: 0]

  setup do 
    Dropbox.Setup.connect
  end
  
  test "fetch client without error", %{client: client} do 
    {:ok, account} = 
    Dropbox.Account.account_info(client)
    |> IO.inspect

    assert is_map(account)
  end
end