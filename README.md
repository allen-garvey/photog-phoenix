# Photog Phoenix

Turn your Apple Photos library into a web application

## Dependencies

* node >= 8
* npm
* elixir >= 1.5
* exiftool
* ImageMagick (optional, required for shutterbug mix task)

## Getting Started

* Install dependencies with `mix deps.get && npm install`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Compile JavaScript and Sass files with `npm run webpack:dev`
* Run the command `mkdir -p priv/static/media/images && mkdir -p priv/static/media/thumbnails` to create the folders for images
* Create a system link from your Apple Photos library `Masters` folder to the `images` folder you just created, and a system link from your Apple Photos library `Thumbnails` folder to the `thumbnails` folder you just created 
* Start Phoenix endpoint with `mix phx.server`
* Now you can visit [`localhost:3000`](http://localhost:3000) from your browser

## Importing Apple Photos Library Database

* Setup the project by following the getting started guide
* Run the export script in the [Photog-spark project](https://github.com/allen-garvey/photog-spark) to export your Photos Library as a SQL file
* Import the file by running `psql photog_dev < your-export-file.sql`

## License

Photog Phoenix is released under the MIT License. See license.txt for more details.