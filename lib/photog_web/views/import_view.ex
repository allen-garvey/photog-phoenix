defmodule PhotogWeb.ImportView do
  use PhotogWeb, :view
  alias PhotogWeb.ImportView

  def render("index.json", %{imports: imports}) do
    %{data: render_many(imports, ImportView, "import.json")}
  end

  def render("show.json", %{import: import}) do
    %{data: render_one(import, ImportView, "import.json")}
  end

  def render("import.json", %{import: import}) do
    %{id: import.id,
      import_time: import.import_time}
  end
end
