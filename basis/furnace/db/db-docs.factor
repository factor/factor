USING: help.markup help.syntax db http.server ;
IN: furnace.db

HELP: <db-persistence>
{ $values
    { "responder" "a responder" } { "db" "a database descriptor" }
    { "responder'" db-persistence }
}
{ $description "Wraps a responder with database persistence support. The responder uses a pooled connection bound to " { $link db-connection } ". The connection is returned when the enclosing HTTP request's destructor scope completes, including after an action exits early during validation or authorization." } ;

ARTICLE: "furnace.db" "Furnace database support"
"The " { $vocab-link "furnace.db" } " vocabulary implements a responder which maintains a database connection pool. Connections are returned by the enclosing HTTP request's destructor scope."
{ $subsections <db-persistence> }
"The " { $vocab-link "furnace.alloy" } " vocabulary combines database persistence with several other features." ;

ABOUT: "furnace.db"
