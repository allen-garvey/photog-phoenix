defmodule PhotogWeb.TagController do
  use PhotogWeb, :controller

  alias Photog.Api
  alias Photog.Api.Tag

  action_fallback PhotogWeb.FallbackController

  def index(conn, _params) do
    tags = Api.list_tags()
    render(conn, "index.json", tags: tags)
  end

  def create(conn, %{"tag" => tag_params}) do
    with {:ok, %Tag{} = tag} <- Api.create_tag(tag_params) do
      conn
      |> put_status(:created)
      |> render("show_excerpt.json", tag: tag)
    end
  end

  def show(conn, %{"id" => id}) do
    tag = Api.get_tag!(id)
    render(conn, "show.json", tag: tag)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Api.get_tag!(id)

    with {:ok, %Tag{} = tag} <- Api.update_tag(tag, tag_params) do
      render(conn, "show_excerpt.json", tag: tag)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Api.get_tag!(id)

    with {:ok, %Tag{}} <- Api.delete_tag(tag) do
      send_resp(conn, :no_content, "")
    end
  end
end
