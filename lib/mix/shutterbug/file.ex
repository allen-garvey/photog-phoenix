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
  """
  def is_image_filename(filename) do
  	!File.dir?(filename) and Regex.match?(~r/^\.(jpg|jpeg|png)$/, Path.extname(filename))
  end

  @doc """
  Copies source to destination but exits with error if destination file already exists
  """
  def safe_copy(source_path, destination_path) do
    File.cp!(source_path, destination_path, fn _,  dest -> Shutterbug.exit_with_error("#{dest} already exists", :dest_file_already_exists) end)
  end

end
