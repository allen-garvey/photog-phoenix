defmodule Photog.Api.Image do
  use Ecto.Schema
  import Ecto.Changeset


  schema "images" do
    field :apple_photos_id, :integer
    field :creation_time, :utc_datetime
    field :is_favorite, :boolean, default: false
    field :master_path, :string
    field :mini_thumbnail_path, :string
    field :thumbnail_path, :string

    timestamps()

    belongs_to :import, Photog.Api.Import

    has_many :album_images, Photog.Api.AlbumImage

    many_to_many :albums, Photog.Api.Album, join_through: "album_images"
    many_to_many :persons, Photog.Api.Person, join_through: "person_images"
  end

  @doc """
  Validates that import_id is not null if apple_photos_id is not null
  Images from apple photos will have no import id, but if image has been imported using mix task,
  they should have an import_id but no apple photos id
  """
  def validate_import_id(changeset, import_id_key, apple_photos_id_key) do
    if is_nil(get_field(changeset, import_id_key)) and is_nil(get_field(changeset, apple_photos_id_key)) do
      add_error(changeset, import_id_key, "Import id cannot be blank if apple photos is blank")
    else
      changeset
    end
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:apple_photos_id, :creation_time, :master_path, :thumbnail_path, :mini_thumbnail_path, :is_favorite, :import_id])
    |> validate_required([:creation_time, :master_path, :thumbnail_path, :mini_thumbnail_path, :is_favorite])
    |> validate_import_id(:import_id, :apple_photos_id)
    |> assoc_constraint(:import)
    |> unique_constraint(:master_path)
    |> unique_constraint(:apple_photos_id)
  end
end
