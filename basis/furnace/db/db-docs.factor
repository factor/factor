USING: help.markup help.syntax db http.server ;
IN: furnace.db

HELP: <db-persistence>
{ $values
    { "responder" "a responder" } { "db" "a database descriptor" }
    { "responder'" db-persistence }
}
{ $description "Wraps a responder with database persistence support. The responder's " { $link call-responder* } " method will run in a " { $link with-db } " scope." } ;

ARTICLE: "furnace.db" "Furnace database support"
"The " { $vocab-link "furnace.db" } " vocabulary implements a responder which maintains a database connection pool and runs each request in a " { $link with-db } " scope."
{ $subsections <db-persistence> }
"The " { $vocab-link "furnace.alloy" } " vocabulary combines database persistence with several other features." ;

ABOUT: "furnace.db"
