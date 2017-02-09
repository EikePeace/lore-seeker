Search engine for official and custom Magic: The Gathering cards.

### Ruby on Rails frontend

To run frontend like http://loreseeker.fenhl.net/

    $ cd frontend
    $ bundle
    $ bundle exec rails s

### Command line

To search card names from command line:

    $ ./bin/find_cards "query"

To search card names and content from command line:

    $ ./bin/find_cards -v "query"

To explore card database from Ruby console:

    $ ./bin/pry_cards

### Testing

Tests for library and for Rails frontend are separate:

    $ bundle install
    $ bundle exec rake test
    $ (cd frontend; bundle install)
    $ (cd frontend; bundle exec rake test)

### How to update database

Whenever new set is released:

* Run `rake rules:update` in case Comprehensive Rules changed
* If set is not Vintage-legale, add new set code to FormatVintage exclusions list
* Add new set code and date to legalities in Standard and Modern if applicable
* Add new set code to appropriate block in indexer
* Create new block format if applicable and add it to indexer and Format class
* Update format tests
* `rake pennydreadful:update`

Then import cards:

* Run `rake mtgjson:update` to fetch mtgjson data and index it
* Run `rake test` and fix any tests failing due to data changes

Whenever banned and restricted list is announced:

* Update `BanlistTest` and/or `BanlistCommanderTest`
* Update `Banlist` data
