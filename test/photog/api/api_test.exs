defmodule Photog.ApiTest do
  use Photog.DataCase

  alias Photog.Api

  describe "folders" do
    alias Photog.Api.Folder

    @valid_attrs %{apple_photos_uuid: "some apple_photos_uuid", name: "some name"}
    @update_attrs %{apple_photos_uuid: "some updated apple_photos_uuid", name: "some updated name"}
    @invalid_attrs %{apple_photos_uuid: nil, name: nil}

    def folder_fixture(attrs \\ %{}) do
      {:ok, folder} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_folder()

      folder
    end

    test "list_folders/0 returns all folders" do
      folder = folder_fixture()
      assert Api.list_folders() == [folder]
    end

    test "get_folder!/1 returns the folder with given id" do
      folder = folder_fixture()
      assert Api.get_folder!(folder.id) == folder
    end

    test "create_folder/1 with valid data creates a folder" do
      assert {:ok, %Folder{} = folder} = Api.create_folder(@valid_attrs)
      assert folder.apple_photos_uuid == "some apple_photos_uuid"
      assert folder.name == "some name"
    end

    test "create_folder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_folder(@invalid_attrs)
    end

    test "update_folder/2 with valid data updates the folder" do
      folder = folder_fixture()
      assert {:ok, folder} = Api.update_folder(folder, @update_attrs)
      assert %Folder{} = folder
      assert folder.apple_photos_uuid == "some updated apple_photos_uuid"
      assert folder.name == "some updated name"
    end

    test "update_folder/2 with invalid data returns error changeset" do
      folder = folder_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_folder(folder, @invalid_attrs)
      assert folder == Api.get_folder!(folder.id)
    end

    test "delete_folder/1 deletes the folder" do
      folder = folder_fixture()
      assert {:ok, %Folder{}} = Api.delete_folder(folder)
      assert_raise Ecto.NoResultsError, fn -> Api.get_folder!(folder.id) end
    end

    test "change_folder/1 returns a folder changeset" do
      folder = folder_fixture()
      assert %Ecto.Changeset{} = Api.change_folder(folder)
    end
  end

  describe "images" do
    alias Photog.Api.Image

    @valid_attrs %{apple_photos_id: 42, creation_time: "2010-04-17 14:00:00.000000Z", is_favorite: true, master_path: "some master_path", mini_thumbnail_path: "some mini_thumbnail_path", thumbnail_path: "some thumbnail_path"}
    @update_attrs %{apple_photos_id: 43, creation_time: "2011-05-18 15:01:01.000000Z", is_favorite: false, master_path: "some updated master_path", mini_thumbnail_path: "some updated mini_thumbnail_path", thumbnail_path: "some updated thumbnail_path"}
    @invalid_attrs %{apple_photos_id: nil, creation_time: nil, is_favorite: nil, master_path: nil, mini_thumbnail_path: nil, thumbnail_path: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Api.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Api.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Api.create_image(@valid_attrs)
      assert image.apple_photos_id == 42
      assert image.creation_time == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert image.is_favorite == true
      assert image.master_path == "some master_path"
      assert image.mini_thumbnail_path == "some mini_thumbnail_path"
      assert image.thumbnail_path == "some thumbnail_path"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, image} = Api.update_image(image, @update_attrs)
      assert %Image{} = image
      assert image.apple_photos_id == 43
      assert image.creation_time == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert image.is_favorite == false
      assert image.master_path == "some updated master_path"
      assert image.mini_thumbnail_path == "some updated mini_thumbnail_path"
      assert image.thumbnail_path == "some updated thumbnail_path"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_image(image, @invalid_attrs)
      assert image == Api.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Api.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Api.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Api.change_image(image)
    end
  end

  describe "albums" do
    alias Photog.Api.Album

    @valid_attrs %{apple_photos_id: 42, folder_order: 42, name: "some name"}
    @update_attrs %{apple_photos_id: 43, folder_order: 43, name: "some updated name"}
    @invalid_attrs %{apple_photos_id: nil, folder_order: nil, name: nil}

    def album_fixture(attrs \\ %{}) do
      {:ok, album} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_album()

      album
    end

    test "list_albums/0 returns all albums" do
      album = album_fixture()
      assert Api.list_albums() == [album]
    end

    test "get_album!/1 returns the album with given id" do
      album = album_fixture()
      assert Api.get_album!(album.id) == album
    end

    test "create_album/1 with valid data creates a album" do
      assert {:ok, %Album{} = album} = Api.create_album(@valid_attrs)
      assert album.apple_photos_id == 42
      assert album.folder_order == 42
      assert album.name == "some name"
    end

    test "create_album/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_album(@invalid_attrs)
    end

    test "update_album/2 with valid data updates the album" do
      album = album_fixture()
      assert {:ok, album} = Api.update_album(album, @update_attrs)
      assert %Album{} = album
      assert album.apple_photos_id == 43
      assert album.folder_order == 43
      assert album.name == "some updated name"
    end

    test "update_album/2 with invalid data returns error changeset" do
      album = album_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_album(album, @invalid_attrs)
      assert album == Api.get_album!(album.id)
    end

    test "delete_album/1 deletes the album" do
      album = album_fixture()
      assert {:ok, %Album{}} = Api.delete_album(album)
      assert_raise Ecto.NoResultsError, fn -> Api.get_album!(album.id) end
    end

    test "change_album/1 returns a album changeset" do
      album = album_fixture()
      assert %Ecto.Changeset{} = Api.change_album(album)
    end
  end

  describe "persons" do
    alias Photog.Api.Person

    @valid_attrs %{apple_photos_id: 42, name: "some name"}
    @update_attrs %{apple_photos_id: 43, name: "some updated name"}
    @invalid_attrs %{apple_photos_id: nil, name: nil}

    def person_fixture(attrs \\ %{}) do
      {:ok, person} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_person()

      person
    end

    test "list_persons/0 returns all persons" do
      person = person_fixture()
      assert Api.list_persons() == [person]
    end

    test "get_person!/1 returns the person with given id" do
      person = person_fixture()
      assert Api.get_person!(person.id) == person
    end

    test "create_person/1 with valid data creates a person" do
      assert {:ok, %Person{} = person} = Api.create_person(@valid_attrs)
      assert person.apple_photos_id == 42
      assert person.name == "some name"
    end

    test "create_person/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_person(@invalid_attrs)
    end

    test "update_person/2 with valid data updates the person" do
      person = person_fixture()
      assert {:ok, person} = Api.update_person(person, @update_attrs)
      assert %Person{} = person
      assert person.apple_photos_id == 43
      assert person.name == "some updated name"
    end

    test "update_person/2 with invalid data returns error changeset" do
      person = person_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_person(person, @invalid_attrs)
      assert person == Api.get_person!(person.id)
    end

    test "delete_person/1 deletes the person" do
      person = person_fixture()
      assert {:ok, %Person{}} = Api.delete_person(person)
      assert_raise Ecto.NoResultsError, fn -> Api.get_person!(person.id) end
    end

    test "change_person/1 returns a person changeset" do
      person = person_fixture()
      assert %Ecto.Changeset{} = Api.change_person(person)
    end
  end

  describe "person_images" do
    alias Photog.Api.PersonImage

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def person_image_fixture(attrs \\ %{}) do
      {:ok, person_image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_person_image()

      person_image
    end

    test "list_person_images/0 returns all person_images" do
      person_image = person_image_fixture()
      assert Api.list_person_images() == [person_image]
    end

    test "get_person_image!/1 returns the person_image with given id" do
      person_image = person_image_fixture()
      assert Api.get_person_image!(person_image.id) == person_image
    end

    test "create_person_image/1 with valid data creates a person_image" do
      assert {:ok, %PersonImage{} = person_image} = Api.create_person_image(@valid_attrs)
    end

    test "create_person_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_person_image(@invalid_attrs)
    end

    test "update_person_image/2 with valid data updates the person_image" do
      person_image = person_image_fixture()
      assert {:ok, person_image} = Api.update_person_image(person_image, @update_attrs)
      assert %PersonImage{} = person_image
    end

    test "update_person_image/2 with invalid data returns error changeset" do
      person_image = person_image_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_person_image(person_image, @invalid_attrs)
      assert person_image == Api.get_person_image!(person_image.id)
    end

    test "delete_person_image/1 deletes the person_image" do
      person_image = person_image_fixture()
      assert {:ok, %PersonImage{}} = Api.delete_person_image(person_image)
      assert_raise Ecto.NoResultsError, fn -> Api.get_person_image!(person_image.id) end
    end

    test "change_person_image/1 returns a person_image changeset" do
      person_image = person_image_fixture()
      assert %Ecto.Changeset{} = Api.change_person_image(person_image)
    end
  end

  describe "album_images" do
    alias Photog.Api.AlbumImage

    @valid_attrs %{order: 42}
    @update_attrs %{order: 43}
    @invalid_attrs %{order: nil}

    def album_image_fixture(attrs \\ %{}) do
      {:ok, album_image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_album_image()

      album_image
    end

    test "list_album_images/0 returns all album_images" do
      album_image = album_image_fixture()
      assert Api.list_album_images() == [album_image]
    end

    test "get_album_image!/1 returns the album_image with given id" do
      album_image = album_image_fixture()
      assert Api.get_album_image!(album_image.id) == album_image
    end

    test "create_album_image/1 with valid data creates a album_image" do
      assert {:ok, %AlbumImage{} = album_image} = Api.create_album_image(@valid_attrs)
      assert album_image.order == 42
    end

    test "create_album_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_album_image(@invalid_attrs)
    end

    test "update_album_image/2 with valid data updates the album_image" do
      album_image = album_image_fixture()
      assert {:ok, album_image} = Api.update_album_image(album_image, @update_attrs)
      assert %AlbumImage{} = album_image
      assert album_image.order == 43
    end

    test "update_album_image/2 with invalid data returns error changeset" do
      album_image = album_image_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_album_image(album_image, @invalid_attrs)
      assert album_image == Api.get_album_image!(album_image.id)
    end

    test "delete_album_image/1 deletes the album_image" do
      album_image = album_image_fixture()
      assert {:ok, %AlbumImage{}} = Api.delete_album_image(album_image)
      assert_raise Ecto.NoResultsError, fn -> Api.get_album_image!(album_image.id) end
    end

    test "change_album_image/1 returns a album_image changeset" do
      album_image = album_image_fixture()
      assert %Ecto.Changeset{} = Api.change_album_image(album_image)
    end
  end
end
