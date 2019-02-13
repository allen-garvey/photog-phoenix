defmodule PhotogWeb.ImportController do
  use PhotogWeb, :controller

  alias Photog.Api
  alias Photog.Api.Import

  action_fallback PhotogWeb.FallbackController

  def index(conn, _params) do
    imports = Api.list_imports()
    render(conn, "index.json", imports: imports)
  end

  def create(conn, %{"import" => import_params}) do
    with {:ok, %Import{} = import} <- Api.create_import(import_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.import_path(conn, :show, import))
      |> render("show.json", import: import)
    end
  end

  def show(conn, %{"id" => id}) do
    import = Api.get_import!(id)
    render(conn, "show.json", import: import)
  end

  def update(conn, %{"id" => id, "import" => import_params}) do
    import = Api.get_import!(id)

    with {:ok, %Import{} = import} <- Api.update_import(import, import_params) do
      render(conn, "show.json", import: import)
    end
  end

  def delete(conn, %{"id" => id}) do
    import = Api.get_import!(id)

    with {:ok, %Import{}} <- Api.delete_import(import) do
      send_resp(conn, :no_content, "")
    end
  end
end
