# Set up 'sniffle' Rails application with 'scripts-to-rule-them-all'

This PR sets up the 'sniffle' Rails application using the latest version of Rails and includes a 'scripts' directory following the 'scripts-to-rule-them-all' process. The scripts automate the setup tasks such as installing dependencies, setting up, and migrating the database.

The Ruby version is pinned to 3.2, and rbenv is used for Ruby version management. SQLite is used as the database for this vanilla Rails application.

To test the setup, clone the repository, run `script/setup`, and you should see a Rails hello-world.

Link to Devin run: https://preview.devin.ai/devin/0f39d4f31b47492b92d1353fc042e9eb

Requested by: Rhett
