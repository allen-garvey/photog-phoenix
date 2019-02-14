defmodule Photog.Shutterbug.File do
  alias Mix.Tasks.Shutterbug

  @doc """
  Returns list of image files for a given directory
  """
  def get_image_files(directory_name) do
  	File.ls!(directory_name)
  	|> Enum.filter(&is_image_filename/1)
  end

  @doc """
  Checks file extension to see if file is image
  Possibly in the future use `mimetype` command instead, but that will be less portable
  Not checking for .tiff since not all browsers can show them
  Could potentially add .gif in future, but no need for it now
  """
  def is_image_filename(filename) do
  	!File.dir?(filename) and Regex.match?(~r/^\.(jpg|jpeg|png)$/, Path.extname(filename))
  end

  @doc """
  Copies source to destination but exits with error if destination file already exists
  """
  def safe_copy(source_path, destination_path) do
    File.cp!(source_path, destination_path, fn _,  dest -> Shutterbug.exit_with_error("#{dest} already exists", :dest_file_already_exists) end)
    # make sure permissions are good, since some devices (such as phones) can have too restrictive permissions which won't allow web server to serve image file
    File.chmod!(destination_path, 0o644)
  end

  @doc """
  Resizes image to given dimension on shortest side using imagemagick
  Resize on largest side from: https://www.imagemagick.org/discourse-server/viewtopic.php?t=13175
  """
  def resize_image(image_source_path, image_destination_path, size) when is_integer(size) do
    with {_, 0} <- System.cmd("convert", [image_source_path, "-resize", "#{size}^>", "-quality", "80%", image_destination_path]) do
      # not sure if we need to do this, because don't know if imagemagick copies file permissions
      File.chmod!(image_destination_path, 0o644)
    else
      _ -> Shutterbug.exit_with_error("Error creating #{image_destination_path} using convert", :error_creating_thumbnail)
    end
  end

end
