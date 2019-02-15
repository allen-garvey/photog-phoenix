defmodule PhotogWeb.Router do
  use PhotogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", PhotogWeb do
    pipe_through :api

    resources "/folders", FolderController,             only: [:index, :show]
    resources "/images", ImageController,               only: [:index, :show]
    resources "/albums", AlbumController,               only: [:index, :show]
    resources "/persons", PersonController,             only: [:index, :show]
    resources "/person_images", PersonImageController,  only: [:index, :show]
    resources "/album_images", AlbumImageController,    only: [:index, :show]
    resources "/imports", ImportController,             only: [:index, :show]

    get "/images/:id/exif", ImageController, :exif_for

    # Edit album images
    get "/images/:id/albums",               ImageController, :albums_for
    post "/images/:id/albums",              ImageController, :add_albums
    delete "/images/:id/albums/:album_id",  ImageController, :remove_album

    # Edit person images
    get "/images/:id/persons",              ImageController, :persons_for
  end

  scope "/", PhotogWeb do
    pipe_through :browser # Use the default browser stack

    # catch all requests and send index page for single page application
    # note this has to be the last route, since routes declared after this one won't be triggered
    # https://elixirforum.com/t/how-to-change-routes-for-single-page-application/3954
    get "/*path", PageController, :index
  end
end
