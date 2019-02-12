defmodule Mix.Tasks.Shutterbug do
  use Mix.Task

  @moduledoc """
  Given a directory of images, will copy image files to masters directory, create thumbnails, and add image resources to database
  """

  @shortdoc "Imports images from given folder"
  def run([source_directory_name, target_directory_name]) do
  	cond do
  		!File.exists?(source_directory_name) -> bad_arguments_exit("#{source_directory_name} does not exist")
  		!File.dir?(source_directory_name)    -> bad_arguments_exit("#{source_directory_name} is not a directory")
  		!File.exists?(target_directory_name) -> bad_arguments_exit("#{target_directory_name} does not exist")
  		!File.dir?(target_directory_name)    -> bad_arguments_exit("#{target_directory_name} is not a directory")
  		true						  -> import_images_from_directory(source_directory_name, target_directory_name)
  	end
  end

  def run(_args) do
  	bad_arguments_exit("usage: mix shutterbug <image_source_directory> <image_library_destination_directory>")
  end

  def bad_arguments_exit(error_message) do
  	IO.puts :stderr, error_message
  	exit(:invalid_commandline_arguments)
  end

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
  Imports image files from directory
  """
  def import_images_from_directory(source_directory_name, target_directory_name) do
  	image_files = get_image_files(source_directory_name)
  	for image_file <- image_files do
  		IO.puts image_file
  	end
  end
end