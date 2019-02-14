defmodule Photog.Api do
  @moduledoc """
  The Api context.
  """

  import Ecto.Query, warn: false
  alias Photog.Repo

  alias Photog.Api.Folder
  alias Photog.Api.Album
  alias Photog.Api.AlbumImage
  alias Photog.Api.PersonImage
  alias Photog.Api.Image
  alias Photog.Api.Person
  alias Photog.Api.Import

  @doc """
  Returns the list of folders.

  ## Examples

      iex> list_folders()
      [%Folder{}, ...]

  """
  def list_folders do
    Repo.all(Folder)
  end

  @doc """
  Gets a single folder.

  Raises `Ecto.NoResultsError` if the Folder does not exist.

  ## Examples

      iex> get_folder!(123)
      %Folder{}

      iex> get_folder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_folder!(id) do
    #better than using separate preload, since only uses 1 query
    #https://hexdocs.pm/ecto/Ecto.Query.html#preload/3

    albums_query = from album in Album,
                      join: cover_image in assoc(album, :cover_image),
                      order_by: album.folder_order,
                      preload: [cover_image: cover_image]

    Repo.one! from folder in Folder,
           join:  album in assoc(folder, :albums),
           where: folder.id == ^id,
           preload: [albums: ^albums_query],
           limit: 1

  end

  @doc """
  Creates a folder.

  ## Examples

      iex> create_folder(%{field: value})
      {:ok, %Folder{}}

      iex> create_folder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_folder(attrs \\ %{}) do
    %Folder{}
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a folder.

  ## Examples

      iex> update_folder(folder, %{field: new_value})
      {:ok, %Folder{}}

      iex> update_folder(folder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_folder(%Folder{} = folder, attrs) do
    folder
    |> Folder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Folder.

  ## Examples

      iex> delete_folder(folder)
      {:ok, %Folder{}}

      iex> delete_folder(folder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_folder(%Folder{} = folder) do
    Repo.delete(folder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking folder changes.

  ## Examples

      iex> change_folder(folder)
      %Ecto.Changeset{source: %Folder{}}

  """
  def change_folder(%Folder{} = folder) do
    Folder.changeset(folder, %{})
  end

  @doc """
  Preloads image import
  """
  def image_preload_import(query) do
    query
    |> join(:left, [image], import in assoc(image, :import))
    |> preload([image, import], [import: import])
  end

  @doc """
  Default preloads when getting retrieving images
  """
  def image_default_preloads(results) do
    results
    |> Repo.preload(albums: from(Album, order_by: :name))
    |> Repo.preload(persons: from(Person, order_by: :name))
  end

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images do
    from(Image, order_by: [desc: :creation_time, desc: :id])
    |> image_preload_import
    |> Repo.all
    |> image_default_preloads
  end

  @doc """
  Returns the list of images that are marked as favorite.

  ## Examples

      iex> list_image_favorites()
      [%Image{}, ...]

  """
  def list_image_favorites(is_favorite) do
    from(image in Image, where: image.is_favorite == ^is_favorite, order_by: [desc: :creation_time, desc: :id])
    |> image_preload_import
    |> Repo.all
    |> image_default_preloads
  end

  @doc """
  Returns the list of images that are not in any albums

  ## Examples

      iex> list_images_not_in_album()
      [%Image{}, ...]

  """
  def list_images_not_in_album() do
    from(
        image in Image,
        left_join: album_image in assoc(image, :album_images),
        where: is_nil(album_image.image_id),
        order_by: [desc: image.creation_time, desc: image.id]
    )
    |> image_preload_import
    |> Repo.all
    |> image_default_preloads
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id) do
    from(image in Image, where: image.id == ^id)
    |> image_preload_import
    |> Repo.one!
    |> image_default_preloads
  end

  @doc """
  Gets albums not used by an image given by id
  """
  def list_image_albums_unused(image_id) do
    album_images_suquery = from(
                                album_image in AlbumImage,
                                where: album_image.image_id == ^image_id,
                                distinct: album_image.album_id,
                                select: %{album_id: album_image.album_id}
                            )

    from(
        album in Album,
        left_join: album_image in subquery(album_images_suquery),
        on: album.id == album_image.album_id,
        where: is_nil(album_image.album_id),
        order_by: [album.name, album.id]
    )
    |> Repo.all
  end

  @doc """
  Gets persons not used by an image given by id
  """
  def list_image_persons_unused(image_id) do
    person_images_suquery = from(
                                person_image in PersonImage,
                                where: person_image.image_id == ^image_id,
                                distinct: person_image.person_id,
                                select: %{person_id: person_image.person_id}
                            )

    from(
        person in Person,
        left_join: person_image in subquery(person_images_suquery),
        on: person.id == person_image.person_id,
        where: is_nil(person_image.person_id),
        order_by: [person.name, person.id]
    )
    |> Repo.all
  end

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{source: %Image{}}

  """
  def change_image(%Image{} = image) do
    Image.changeset(image, %{})
  end

  @doc """
  Returns the list of albums.

  ## Examples

      iex> list_albums()
      [%Album{}, ...]

  """
  def list_albums do
    #better than using separate preload, since only uses 1 query
    #https://hexdocs.pm/ecto/Ecto.Query.html#preload/3
    Repo.all from album in Album,
          join: cover_image in assoc(album, :cover_image),
          preload: [cover_image: cover_image],
          order_by: :id
  end

  @doc """
  Gets a single album.

  Raises `Ecto.NoResultsError` if the Album does not exist.

  ## Examples

      iex> get_album!(123)
      %Album{}

      iex> get_album!(456)
      ** (Ecto.NoResultsError)

  """
  def get_album!(id) do
    # for some reason, if you put subquery directly in preload, it causes an error
    image_albums_query = from(Album, order_by: :name)
    image_persons_query = from(Person, order_by: :name)
    images_query = from image in Image,
                      join: album_image in assoc(image, :album_images),
                      left_join: import in assoc(image, :import),
                      where: album_image.album_id == ^id,
                      preload: [albums: ^image_albums_query, persons: ^image_persons_query, import: import],
                      order_by: album_image.image_order

    Repo.one!(from album in Album,
                      join: image in assoc(album, :images),
                      where: album.id == ^id,
                      preload: [cover_image: image, images: ^images_query],
                      limit: 1)
  end

  @doc """
  Creates a album.

  ## Examples

      iex> create_album(%{field: value})
      {:ok, %Album{}}

      iex> create_album(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a album.

  ## Examples

      iex> update_album(album, %{field: new_value})
      {:ok, %Album{}}

      iex> update_album(album, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album(%Album{} = album, attrs) do
    album
    |> Album.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Album.

  ## Examples

      iex> delete_album(album)
      {:ok, %Album{}}

      iex> delete_album(album)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album(%Album{} = album) do
    Repo.delete(album)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album changes.

  ## Examples

      iex> change_album(album)
      %Ecto.Changeset{source: %Album{}}

  """
  def change_album(%Album{} = album) do
    Album.changeset(album, %{})
  end

  @doc """
  Returns the list of persons.

  ## Examples

      iex> list_persons()
      [%Person{}, ...]

  """
  def list_persons do
    #better than using separate preload, since only uses 1 query
    #https://hexdocs.pm/ecto/Ecto.Query.html#preload/3
    Repo.all from person in Person,
          join: cover_image in assoc(person, :cover_image),
          preload: [cover_image: cover_image],
          order_by: :name
  end

  @doc """
  Gets a single person.

  Raises `Ecto.NoResultsError` if the Person does not exist.

  ## Examples

      iex> get_person!(123)
      %Person{}

      iex> get_person!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person!(id) do
    #better than using separate preload, since only uses 1 query
    #https://hexdocs.pm/ecto/Ecto.Query.html#preload/3
    # for some reason, if you put subquery directly in preload, it causes an error
    image_albums_query = from(Album, order_by: :name)
    image_persons_query = from(Person, order_by: :name)
    images_query = from image in Image,
                      join: person_image in assoc(image, :person_images),
                      left_join: import in assoc(image, :import),
                      where: person_image.person_id == ^id,
                      preload: [albums: ^image_albums_query, persons: ^image_persons_query, import: import],
                      order_by: [desc: image.creation_time]

    Repo.one! from person in Person,
           join:  image in assoc(person, :images),
           where: person.id == ^id,
           preload: [images: ^images_query, cover_image: image],
           limit: 1
  end

  @doc """
  Creates a person.

  ## Examples

      iex> create_person(%{field: value})
      {:ok, %Person{}}

      iex> create_person(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person(attrs \\ %{}) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person.

  ## Examples

      iex> update_person(person, %{field: new_value})
      {:ok, %Person{}}

      iex> update_person(person, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person(%Person{} = person, attrs) do
    person
    |> Person.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Person.

  ## Examples

      iex> delete_person(person)
      {:ok, %Person{}}

      iex> delete_person(person)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person(%Person{} = person) do
    Repo.delete(person)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person changes.

  ## Examples

      iex> change_person(person)
      %Ecto.Changeset{source: %Person{}}

  """
  def change_person(%Person{} = person) do
    Person.changeset(person, %{})
  end

  @doc """
  Returns the list of person_images.

  ## Examples

      iex> list_person_images()
      [%PersonImage{}, ...]

  """
  def list_person_images do
    Repo.all(PersonImage)
  end

  @doc """
  Gets a single person_image.

  Raises `Ecto.NoResultsError` if the Person image does not exist.

  ## Examples

      iex> get_person_image!(123)
      %PersonImage{}

      iex> get_person_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_person_image!(id), do: Repo.get!(PersonImage, id)

  @doc """
  Creates a person_image.

  ## Examples

      iex> create_person_image(%{field: value})
      {:ok, %PersonImage{}}

      iex> create_person_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_person_image(attrs \\ %{}) do
    %PersonImage{}
    |> PersonImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person_image.

  ## Examples

      iex> update_person_image(person_image, %{field: new_value})
      {:ok, %PersonImage{}}

      iex> update_person_image(person_image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_person_image(%PersonImage{} = person_image, attrs) do
    person_image
    |> PersonImage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PersonImage.

  ## Examples

      iex> delete_person_image(person_image)
      {:ok, %PersonImage{}}

      iex> delete_person_image(person_image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_person_image(%PersonImage{} = person_image) do
    Repo.delete(person_image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person_image changes.

  ## Examples

      iex> change_person_image(person_image)
      %Ecto.Changeset{source: %PersonImage{}}

  """
  def change_person_image(%PersonImage{} = person_image) do
    PersonImage.changeset(person_image, %{})
  end

  @doc """
  Returns the list of album_images.

  ## Examples

      iex> list_album_images()
      [%AlbumImage{}, ...]

  """
  def list_album_images do
    Repo.all(AlbumImage)
  end

  @doc """
  Gets a single album_image.

  Raises `Ecto.NoResultsError` if the Album image does not exist.

  ## Examples

      iex> get_album_image!(123)
      %AlbumImage{}

      iex> get_album_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_album_image!(id), do: Repo.get!(AlbumImage, id)

  @doc """
  Creates a album_image.

  ## Examples

      iex> create_album_image(%{field: value})
      {:ok, %AlbumImage{}}

      iex> create_album_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_album_image(attrs \\ %{}) do
    %AlbumImage{}
    |> AlbumImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a album_image.

  ## Examples

      iex> update_album_image(album_image, %{field: new_value})
      {:ok, %AlbumImage{}}

      iex> update_album_image(album_image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_album_image(%AlbumImage{} = album_image, attrs) do
    album_image
    |> AlbumImage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a AlbumImage.

  ## Examples

      iex> delete_album_image(album_image)
      {:ok, %AlbumImage{}}

      iex> delete_album_image(album_image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_album_image(%AlbumImage{} = album_image) do
    Repo.delete(album_image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking album_image changes.

  ## Examples

      iex> change_album_image(album_image)
      %Ecto.Changeset{source: %AlbumImage{}}

  """
  def change_album_image(%AlbumImage{} = album_image) do
    AlbumImage.changeset(album_image, %{})
  end

  @doc """
  Returns the list of imports.

  ## Examples

      iex> list_imports()
      [%Import{}, ...]

  """
  def list_imports do
    Repo.all(from(Import, order_by: [desc: :id]))
  end

  @doc """
  Gets a single import.

  Raises `Ecto.NoResultsError` if the Import does not exist.

  ## Examples

      iex> get_import!(123)
      %Import{}

      iex> get_import!(456)
      ** (Ecto.NoResultsError)

  """
  def get_import!(id) do
    # for some reason, if you put subquery directly in preload, it causes an error
    image_albums_query = from(Album, order_by: :name)
    image_persons_query = from(Person, order_by: :name)
    images_query = from image in Image,
                      #can use join here instead of left join since we know it has to have an import
                      join: import in assoc(image, :import),
                      where: image.import_id == ^id,
                      preload: [albums: ^image_albums_query, persons: ^image_persons_query, import: import],
                      order_by: [image.creation_time, image.id]

    Repo.get!(Import, id)
    |> Repo.preload(images: images_query)
  end

  @doc """
  Creates a import.

  ## Examples

      iex> create_import(%{field: value})
      {:ok, %Import{}}

      iex> create_import(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_import(attrs \\ %{}) do
    %Import{}
    |> Import.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a import.

  ## Examples

      iex> update_import(import, %{field: new_value})
      {:ok, %Import{}}

      iex> update_import(import, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_import(%Import{} = import, attrs) do
    import
    |> Import.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Import.

  ## Examples

      iex> delete_import(import)
      {:ok, %Import{}}

      iex> delete_import(import)
      {:error, %Ecto.Changeset{}}

  """
  def delete_import(%Import{} = import) do
    Repo.delete(import)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking import changes.

  ## Examples

      iex> change_import(import)
      %Ecto.Changeset{source: %Import{}}

  """
  def change_import(%Import{} = import) do
    Import.changeset(import, %{})
  end
end
