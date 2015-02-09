defmodule Dropbox.Client do
  defstruct client_id: nil,
            client_secret: nil,
            access_token: nil,
            locale: nil,
            root: :dropbox
end