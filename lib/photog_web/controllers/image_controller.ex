defmodule PhotogWeb.ImageController do
  use PhotogWeb, :controller

  alias Photog.Repo
  alias Photog.Api
  alias Photog.Api.Image
  alias Photog.Api.AlbumImage

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
  Gets the exif data from an image's master image
  """
  def exif_for(conn, %{"id" => id}) do
    image = Api.get_image!(id)
    exif_map = Photog.Image.Exif.exif_for(image)
    render(conn, "exif.json", exif: exif_map, image: image)
  end

  @doc """
  Gets the albums unused by an image
  """
  def albums_for(conn, %{"id" => id, "unused" => "true"}) do
    albums = Api.list_image_albums_unused(id)
    render(conn, "albums.json", albums: albums)
  end

  @doc """
  Gets the persons unused by an image
  """
  def persons_for(conn, %{"id" => id, "unused" => "true"}) do
    persons = Api.list_image_persons_unused(id)
    render(conn, "persons.json", persons: persons)
  end

  @doc """
  Adds albums to an image
  tags comma-delimited list of album ids
  """
  def add_albums(conn, %{"id" => image_id, "albums" => albums}) do
    {albums_added, errors} =
      String.split(albums, ",")
      |> Enum.reduce({[], []}, fn album_id, {albums_added, errors} ->
        case Api.create_album_image(%{"image_id" => image_id, "album_id" => album_id}) do
          {:ok, %AlbumImage{} = _album_image} -> { [album_id | albums_added], errors }
          {:error, _changeset}                -> { albums_added, [ album_id | errors] }

        end
      end)

    conn
    |> put_view(PhotogWeb.GenericView)
    |> (&(
      if Enum.empty?(errors) do
        render(&1, "ok.json", message: albums_added)
      else
        render(&1, "mixed_response.json", message: albums_added, error: errors)
      end
    )).()
  end

  @doc """
  Removes a album from an image
  """
  def remove_album(conn, %{"id" => image_id, "album_id" => album_id}) do
    album_image = Repo.get_by!(Artour.PostTag, image_id: image_id, album_id: album_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(album_image)

    # send_resp(conn, :no_content, "")
    conn
    |> put_view(PhotogWeb.GenericView)
    |> render("ok.json", message: "Album removed")
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
