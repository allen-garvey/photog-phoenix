defmodule PhotogWeb.ImportView do
  use PhotogWeb, :view
  alias PhotogWeb.ImportView
  alias PhotogWeb.DatetimeHelpers

  def import_name(import) do
    DatetimeHelpers.to_us_formatted_date(import.import_time)
    <> " "
    <> DatetimeHelpers.to_formatted_time(import.import_time)
  end

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
      name: import_name(import),
    }
  end

  def render("import.json", %{import: import}) do
    %{
      id: import.id,
      import_time: import.import_time,
      name: import_name(import),
      images: Enum.map(import.images, &PhotogWeb.ImageView.image_full_to_map/1),
    }
  end
end
