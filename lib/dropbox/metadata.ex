defmodule Dropbox.Metadata do
  defstruct size: nil,
            bytes: 0,
            path: nil,
            is_dir: false,
            is_deleted: false,
            rev: nil,
            hash: nil,
            thumb_exists: false,
            photo_info: %Dropbox.Metadata.Photo{},
            video_info: %Dropbox.Metadata.Video{},
            icon: nil,
            modified: nil,
            client_mtime: nil,
            contents: %{}
end