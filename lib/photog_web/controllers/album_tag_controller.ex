defmodule PhotogWeb.AlbumTagController do
  use PhotogWeb, :controller

  alias Photog.Api
  alias Photog.Api.AlbumTag

  action_fallback PhotogWeb.FallbackController

  def index(conn, _params) do
    album_tags = Api.list_album_tags()
    render(conn, "index.json", album_tags: album_tags)
  end

  def create(conn, %{"album_tag" => album_tag_params}) do
    with {:ok, %AlbumTag{} = album_tag} <- Api.create_album_tag(album_tag_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", album_tag_path(conn, :show, album_tag))
      |> render("show.json", album_tag: album_tag)
    end
  end

  def show(conn, %{"id" => id}) do
    album_tag = Api.get_album_tag!(id)
    render(conn, "show.json", album_tag: album_tag)
  end

  def update(conn, %{"id" => id, "album_tag" => album_tag_params}) do
    album_tag = Api.get_album_tag!(id)

    with {:ok, %AlbumTag{} = album_tag} <- Api.update_album_tag(album_tag, album_tag_params) do
      render(conn, "show.json", album_tag: album_tag)
    end
  end

  def delete(conn, %{"id" => id}) do
    album_tag = Api.get_album_tag!(id)

    with {:ok, %AlbumTag{}} <- Api.delete_album_tag(album_tag) do
      send_resp(conn, :no_content, "")
    end
  end
end
