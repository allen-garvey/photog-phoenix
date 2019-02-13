defmodule Photog.Shutterbug.File do
  alias Mix.Tasks.Shutterbug

  @doc """
  Copies source to destination but exits with error if destination file already exists
  """
  def safe_copy(source_path, destination_path) do
    File.cp!(source_path, destination_path, fn _,  dest -> Shutterbug.exit_with_error("#{dest} already exists", :dest_file_already_exists) end)
  end

end
