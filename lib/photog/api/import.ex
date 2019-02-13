defmodule Photog.Api.Import do
  use Ecto.Schema
  import Ecto.Changeset


  schema "imports" do
    field :import_time, :utc_datetime

    timestamps()

    has_many :images, Photog.Api.Image
  end

  @doc false
  def changeset(import, attrs) do
    import
    |> cast(attrs, [:import_time])
    |> validate_required([:import_time])
  end
end
