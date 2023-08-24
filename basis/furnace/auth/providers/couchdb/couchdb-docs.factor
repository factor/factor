USING: furnace.auth.providers help.markup help.syntax ;
IN: furnace.auth.providers.couchdb

HELP: couchdb-auth-provider
{
    $class-description "Implements the furnace authentication protocol for CouchDB."
    { $slots
      { "base-url" { "The base URL for the CouchDB database, e.g. http://foo.org:5984/mydatabase" } }
      { "username-view" { "A URL for a view which emits usernames as keys and user documents as values, "
                                    "i.e. something like emit(doc.username, doc). The URL should be relative"
                                    " to base-url (e.g. \"_design/my_views/_view/by_username\")."
                                    " The view is not defined automatically by the library." } }
      { "prefix" { "In order to ensure the uniqueness of user IDs and email addresses,"
                             " the library creates documents in the database with ids corresponding to these values. "
                             "These ids "
                             "are prefixed by the string given as the value for this slot. Ideally, you should guarantee that no other "
                             "documents in the database can have ids with this prefix. However, "
                             "the worst that can happen is for someone to falsely be told that a username "
                             "is taken when it is in fact free." } }
      { "field-map" { "An assoc taking " { $link user } " slot names to CouchDB document "
                                "field names. It is not usually necessary to set this slot - it is useful only if "
                                "you do not wish to use the default field names." } }
  }
} ;

ARTICLE: "furnace.auth.providers.couchdb" "CouchDB Authentication Provider"
    "The " { $vocab-link "furnace.auth.providers.couchdb" } " vocabulary implements an authentication provider "
    "which looks up authentication requests in CouchDB. It is necessary to create a view "
    "associating usernames with user documents before using this vocabulary; see documentation "
    "for " { $link couchdb-auth-provider } "."
    $nl
    "Although this implementation guarantees that users with duplicate IDs/emails"
    " cannot be created in a single CouchDB database, it provides no such guarantee if you are clustering "
    "multiple DBs. In this case, you are responsible for ensuring the uniqueness of users across "
    "databases."
    $nl
    "Password hashes are base64 encoded."
 ;

ABOUT: "furnace.auth.providers.couchdb"
