defmodule Photog.Image.Exif do
  alias Photog.Api.Image

  @doc """
  Gets a the exif data from an image's master image using exiftool
  https://stackoverflow.com/questions/26654709/extract-exif-data-as-text-using-imagemagick
  requires the `exiftool` command from libimage-exiftool-perl
  `# exiftool -duplicates -unknown -tab image.jpg`
  """
  def exif_for(%Image{} = image) do
    Photog.Image.master_file_path(image)
    |> exif_for
  end

  def exif_for(image_file_path) when is_binary(image_file_path) do
    with {exif_results, 0} <- System.cmd("exiftool", ["-duplicates", "-unknown", "-json", image_file_path]) do
      # IO.puts(exif_results)
      Poison.decode!(exif_results)
      |> Enum.at(0)
    end
  end
end
