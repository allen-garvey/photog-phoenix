defmodule PhotogWeb.AlbumController do
  use PhotogWeb, :controller

  alias Photog.Api
  alias Photog.Api.Album

  action_fallback PhotogWeb.FallbackController

  def index(conn, %{"excerpt" => "true"}) do
    albums = Api.list_albums_excerpt()
    render(conn, "index_excerpt.json", albums: albums)
  end

  def index(conn, _params) do
    albums = Api.list_albums()
    render(conn, "index.json", albums: albums)
  end

  def create(conn, %{"album" => album_params}) do
    with {:ok, %Album{} = album} <- Api.create_album(album_params) do
      conn
      |> put_status(:created)
      |> render("show.json", album: album)
    end
  end

  def show(conn, %{"id" => id}) do
    album = Api.get_album!(id)
    render(conn, "show.json", album: album)
  end

  def update(conn, %{"id" => id, "album" => album_params}) do
    album = Api.get_album!(id)

    case Api.update_album(album, album_params) do
      {:ok, %Album{} = album} -> render(conn, "show.json", album: album)
      {:error, changeset}     -> conn |> put_view(PhotogWeb.GenericView) |> render("mixed_response.json", message: "Errors updating album", error: Api.changeset_errors(changeset))
    end
  end

  def delete(conn, %{"id" => id}) do
    album = Api.get_album!(id)
    with {:ok, %Album{}} <- Api.delete_album(album) do
      send_resp(conn, :no_content, "")
    end
  end
end
