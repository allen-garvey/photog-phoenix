defmodule Mix.Tasks.Shutterbug do
  use Mix.Task

  alias Photog.Shutterbug.Directory

  @moduledoc """
  Given a directory of images, will copy image files to masters directory, create thumbnails, and add image resources to database
  """

  @shortdoc "Imports images from given folder"
  def run([source_directory_name, target_directory_name]) do
  	cond do
  		!File.exists?(source_directory_name) -> exit_with_error("#{source_directory_name} does not exist")
  		!File.dir?(source_directory_name)    -> exit_with_error("#{source_directory_name} is not a directory")
  		!File.exists?(target_directory_name) -> exit_with_error("#{target_directory_name} does not exist")
  		!File.dir?(target_directory_name)    -> exit_with_error("#{target_directory_name} is not a directory")
  		true						  -> import_images_from_directory(source_directory_name, target_directory_name)
  	end
  end

  def run(_args) do
  	exit_with_error("usage: mix shutterbug <image_source_directory> <image_library_destination_directory>")
  end

  def exit_with_error(error_message, reason \\ :invalid_commandline_arguments) do
  	IO.puts :stderr, error_message
  	exit(reason)
  end

  @doc """
  Imports image files from directory
  """
  def import_images_from_directory(source_directory_name, target_directory_name) do
  	image_files = Photog.Shutterbug.File.get_image_files(source_directory_name)

  	if Enum.empty?(image_files) do
  		exit_with_error("No image files found in #{source_directory_name}", :no_images_in_source_directory)
    end

    #create directories for masters and thumbnails
    now = DateTime.utc_now()
    masters_path = Directory.masters_path(target_directory_name, now)
    thumbnails_path = Directory.thumbnails_path(target_directory_name, now)

    File.mkdir_p!(masters_path)
    File.mkdir_p!(thumbnails_path)

    #start app so repo is available
    Mix.Task.run "app.start", []

    #create import
    import_id = Photog.Shutterbug.Import.create_import()

    for image_file <- image_files do
      IO.puts image_file

      #get image full source path
      image_source_path = Path.join(source_directory_name, image_file)
      # copy image master
      image_master_path = Path.join(masters_path, image_file)
      Photog.Shutterbug.File.safe_copy(image_source_path, image_master_path)

  	end
  end
end
