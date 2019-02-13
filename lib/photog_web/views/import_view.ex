defmodule PhotogWeb.ImportView do
  use PhotogWeb, :view
  alias PhotogWeb.ImportView
  alias PhotogWeb.ViewHelpers.DateHelpers

  def render("index.json", %{imports: imports}) do
    %{data: render_many(imports, ImportView, "import_excerpt.json")}
  end

  def render("show.json", %{import: import}) do
    %{data: render_one(import, ImportView, "import.json")}
  end

  def render("import_excerpt.json", %{import: import}) do
    %{
      id: import.id,
      import_time: import.import_time,
      name: DateHelpers.datetime_to_us_format(import.import_time),
    }
  end

  def render("import.json", %{import: import}) do
    %{
      id: import.id,
      import_time: import.import_time,
      name: DateHelpers.datetime_to_us_format(import.import_time),
      images: Enum.map(import.images, &PhotogWeb.ImageView.image_full_to_map/1),
    }
  end
end
