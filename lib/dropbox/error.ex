defmodule Dropbox.Error do
  defexception [:message, :status]

  def raise_error(reason) do
    case reason do
      {{:http_status, code}, reason} ->
        raise %Dropbox.Error{message: reason, status: code}
      reason ->
        raise %Dropbox.Error{message: reason}
    end
  end

end