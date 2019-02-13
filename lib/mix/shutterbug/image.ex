defmodule Photog.Shutterbug.Image do

  def thumbnail_name(image_name) do
    "thumb_#{Path.rootname(image_name)}.jpg"
  end

  def mini_thumbnail_name(image_name) do
    "thumb_mini_#{Path.rootname(image_name)}.jpg"
  end

end
