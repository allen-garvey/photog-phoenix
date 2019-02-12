defmodule PhotogWeb.ImageController do
  use PhotogWeb, :controller

  alias Photog.Api
  alias Photog.Api.Image

  action_fallback PhotogWeb.FallbackController

  def index(conn, %{"favorites" => is_favorite_param}) do
    images = Api.list_image_favorites(is_favorite_param == "true")
    render(conn, "index.json", images: images)
  end

  def index(conn, %{"in_album" => "false"}) do
    images = Api.list_images_not_in_album()
    render(conn, "index.json", images: images)
  end

  def index(conn, _params) do
    images = Api.list_images()
    render(conn, "index.json", images: images)
  end

  def create(conn, %{"image" => image_params}) do
    with {:ok, %Image{} = image} <- Api.create_image(image_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", image_path(conn, :show, image))
      |> render("show.json", image: image)
    end
  end

  def show(conn, %{"id" => id}) do
    image = Api.get_image!(id)
    render(conn, "show.json", image: image)
  end

  @spec exif_for(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @doc """
  Gets a the exif data from an image's master image using exiftool
  https://stackoverflow.com/questions/26654709/extract-exif-data-as-text-using-imagemagick
  requires the `exiftool` command from libimage-exiftool-perl
  `# exiftool -duplicates -unknown -tab image.jpg`
  """
  def exif_for(conn, %{"id" => id}) do
    image = Api.get_image!(id)
    image_master_full_path = Path.absname("priv/static/media/images") |> Path.join(image.master_path)
    with {exif_results, 0} <- System.cmd("exiftool", ["-duplicates", "-unknown", "-json", image_master_full_path]) do
      # IO.puts(exif_results)
      exif_map = Poison.decode!(exif_results) |> Enum.at(0)
      render(conn, "exif.json", exif: exif_map, image: image)
    end
  end

  def update(conn, %{"id" => id, "image" => image_params}) do
    image = Api.get_image!(id)

    with {:ok, %Image{} = image} <- Api.update_image(image, image_params) do
      render(conn, "show.json", image: image)
    end
  end

  def delete(conn, %{"id" => id}) do
    image = Api.get_image!(id)
    with {:ok, %Image{}} <- Api.delete_image(image) do
      send_resp(conn, :no_content, "")
    end
  end
end
