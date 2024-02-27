USING: help.markup help.syntax db ;
IN: furnace.alloy

HELP: init-furnace-tables
{ $description "Initializes database tables used by asides, conversations and session management. This word must be invoked inside a " { $link with-db } " scope." } ;

HELP: <alloy>
{ $values { "responder" "a responder" } { "db" "a database descriptor" } { "responder'" "an alloy responder" } }
{ $description "Wraps the responder with support for asides, conversations, sessions and database persistence." }
{ $examples
    "The " { $vocab-link "webapps.counter" } " vocabulary uses an alloy to configure the counter:"
    { $code
        ": counter-db ( -- db ) \"counter.db\" <sqlite3-db> ;

: run-counter ( -- )
    <counter-app>
        counter-db <alloy>
        main-responder set-global
    8080 httpd ;"
    }
} ;

HELP: start-expiring
{ $values { "db" "a database descriptor" } }
{ $description "Starts a timer which expires old session state from the given database." } ;

ARTICLE: "furnace.alloy" "Furnace alloy responder"
"The " { $vocab-link "furnace.alloy" } " vocabulary implements a convenience responder which combines several Furnace features into one easy-to-use wrapper:"
{ $list
    { $link "furnace.asides" }
    { $link "furnace.conversations" }
    { $link "furnace.sessions" }
    { $link "furnace.db" }
}
"A word to wrap a responder in an alloy:"
{ $subsections <alloy> }
"Initializing database tables for asides, conversations and sessions:"
{ $subsections init-furnace-tables }
"Start a timer to expire asides, conversations and sessions:"
{ $subsections start-expiring } ;

ABOUT: "furnace.alloy"
