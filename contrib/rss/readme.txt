This library is a simple RSS2 parser and RSS reader web
application. To run the web application you'll need to make sure you
have the sqlite library working. This can be tested with

  "sqlite" require
  "sqlite" test-module

Remember that to use "sqlite" you need to have done the following
somewhere:

  USE: alien
  "sqlite" "/usr/lib/libsqlite3.so" "cdecl" add-library

Replacing "libsqlite3.so" with the path to the sqlite shared library
or DLL. I put this in my ~/.factor-rc.

The RSS reader web application creates a database file called
'rss-reader.db' in the same directory as the Factor executable when
first started. This database contains all the feed information.

To load the web application use:

  "rss" require

Fire up the web server and navigate to the URL:

  http://localhost:8888/responder/maintain-feeds

Add any RSS2 compatible feed. Use 'Update Feeds' to retrieve them and
update the sqlite database with the feed contains. Use 'Database' to
view the entries from the database for that feed.

