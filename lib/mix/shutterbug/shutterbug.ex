defmodule Mix.Tasks.Shutterbug do
  use Mix.Task

  @moduledoc """
  Given a directory of images, will copy image files to masters directory, create thumbnails, and add image resources to database
  """

  @shortdoc "Imports images from given folder"
  def run([directory_name]) do
  	cond do
  		!File.exists?(directory_name) -> bad_arguments_exit("#{directory_name} does not exist")
  		!File.dir?(directory_name)    -> bad_arguments_exit("#{directory_name} is not a directory")
  		true						  -> get_image_files(directory_name)
  	end
  end

  def run(_args) do
  	bad_arguments_exit("usage: mix shutterbug <image_source_directory>")
  end

  def bad_arguments_exit(error_message) do
  	IO.puts :stderr, error_message
  	exit(:invalid_commandline_arguments)
  end

  def get_image_files(directory_name) do
  	files = File.ls!(directory_name)
  	for file <- files do
  		IO.puts file
  	end
  end
end