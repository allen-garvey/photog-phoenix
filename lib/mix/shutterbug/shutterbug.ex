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
    target_relative_path = Directory.import_relative_path(now)
    masters_path = Directory.masters_path(target_directory_name, now)
    thumbnails_path = Directory.thumbnails_path(target_directory_name, now)

    if File.exists?(masters_path) do
      exit_with_error("#{masters_path} already exists", :masters_directory_exists)
    end
    File.mkdir_p!(masters_path)

    if File.exists?(thumbnails_path) do
      exit_with_error("#{thumbnails_path} already exists", :thumbnails_directory_exists)
    end
    File.mkdir_p!(thumbnails_path)

    #start app so repo is available
    Mix.Task.run "app.start", []

    #create import
    import_id = Photog.Shutterbug.Import.create_import()

    for image_file <- image_files do
      IO.puts "Importing #{image_file}"

      #get image full source path
      image_source_path = Path.join(source_directory_name, image_file)
      # copy image master
      image_master_path = Path.join(masters_path, image_file)
      Photog.Shutterbug.File.safe_copy(image_source_path, image_master_path)

      #create thumbnails
      thumbnail_name = Photog.Shutterbug.Image.thumbnail_name(image_file)
      mini_thumbnail_name = Photog.Shutterbug.Image.mini_thumbnail_name(image_file)

      image_thumbnail_path = Path.join(thumbnails_path, thumbnail_name)
      image_mini_thumbnail_path = Path.join(thumbnails_path, mini_thumbnail_name)

      Photog.Shutterbug.File.resize_image(image_source_path, image_thumbnail_path, 768)
      Photog.Shutterbug.File.resize_image(image_source_path, image_mini_thumbnail_path, 250)

      #get paths needed when creating image resource
      image_thumbnail_relative_path = Path.join(target_relative_path, thumbnail_name)
      image_mini_thumbnail_relative_path = Path.join(target_relative_path, mini_thumbnail_name)
      image_master_relative_path = Path.join(target_relative_path, image_file)

      Photog.Shutterbug.Image.create_image!(%{
        master_path: image_master_relative_path,
        mini_thumbnail_path: image_mini_thumbnail_relative_path,
        thumbnail_path: image_thumbnail_relative_path,
        import_id: import_id,
        creation_time: now, #use now for now, but should update to creation time from image master exif
      })

  	end
  end
end
