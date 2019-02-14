defmodule Photog.Api.Album do
  use Ecto.Schema
  import Ecto.Changeset


  schema "albums" do
    field :apple_photos_id, :integer
    field :folder_order, :integer
    field :name, :string

    timestamps()

    belongs_to :cover_image, Photog.Api.Image
    belongs_to :folder, Photog.Api.Folder

    has_many :album_images, Photog.Api.AlbumImage
    many_to_many :images, Photog.Api.Image, join_through: "album_images"
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:apple_photos_id, :name, :folder_order, :folder_id, :cover_image_id])
    |> validate_required([:apple_photos_id, :name, :folder_order, :folder_id, :cover_image_id])
    |> unique_constraint(:apple_photos_id)
    |> assoc_constraint(:folder)
    |> assoc_constraint(:image)
    |> assoc_constraint(:cover_image)
  end
end
