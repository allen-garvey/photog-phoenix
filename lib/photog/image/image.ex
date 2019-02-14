defmodule Photog.Image do
  alias Photog.Api.Image

  def master_file_path(%Image{} = image) do
    Path.absname("priv/static/media/images")
    |> Path.join(image.master_path)
  end
end
