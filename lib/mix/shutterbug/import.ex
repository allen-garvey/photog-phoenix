defmodule Photog.Shutterbug.Import do
  alias Photog.Api

  def create_import do
      import_changeset = Api.change_import()
  end

end
