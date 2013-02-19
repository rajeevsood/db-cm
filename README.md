# Db::Cm

DB-CM is (will be) a DB version management tool based on MyBatis Migrations.  There are some differences in intent, though.  MyBatis Migrationssupports the concept of a single file per migration.  DB-CM will support directory per migration, allowing for separation of the different parts of a migration (i.e. ddl changes, data changes, sprocs, etc) following a convention-over-configuration model.  

Stay posted for more to come as it is developed.

## Installation

Add this line to your application's Gemfile:

    gem 'db-cm'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install db-cm

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
