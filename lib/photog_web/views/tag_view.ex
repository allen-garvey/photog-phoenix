defmodule PhotogWeb.TagView do
  use PhotogWeb, :view
  alias PhotogWeb.TagView

  def render("index.json", %{tags: tags}) do
    %{data: render_many(tags, TagView, "tag_excerpt.json")}
  end

  def render("show.json", %{tag: tag}) do
    %{data: render_one(tag, TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    %{
      id: tag.id,
      name: tag.name,
    }
  end

  def render("tag_excerpt.json", %{tag: tag}) do
    %{id: tag.id,
      name: tag.name}
  end

end
