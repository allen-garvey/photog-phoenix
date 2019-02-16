defmodule Photog.Api.Tag do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tags" do
    field :apple_photos_uuid, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :apple_photos_uuid])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> unique_constraint(:apple_photos_uuid)
  end
end
