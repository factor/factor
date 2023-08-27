USING: calendar furnace.db help.markup help.syntax kernel
words.symbol ;
IN: furnace.sessions

HELP: <sessions>
{ $values
    { "responder" "a responder" }
    { "responder'" "a new responder" }
}
{ $description "Wraps a responder in a session manager responder." } ;

HELP: schange
{ $values { "key" symbol } { "quot" { $quotation ( old -- new ) } } }
{ $description "Applies the quotation to the old value of the session variable, and assigns the resulting value back to the variable." } ;

HELP: sget
{ $values { "key" symbol } { "value" object } }
{ $description "Outputs the value of a session variable." } ;

HELP: sset
{ $values { "value" object } { "key" symbol } }
{ $description "Sets the value of a session variable." } ;

ARTICLE: "furnace.sessions.config" "Session manager configuration"
"The " { $link sessions } " tuple has two slots which contain configuration parameters:"
{ $slots
    { "verify?" { "If set to a true value, the client IP address and user agent of each session is tracked, and checked every time a client attempts to re-establish a session. While this does not offer any real security, it can thwart unskilled packet-sniffing attacks. On by default." } }
    { "timeout" { "A " { $link duration } " storing the maximum time that inactive sessions will be stored on the server. The default timeout is 20 minutes. Note that for sessions to actually expire, you must start a thread to do so; see the " { $vocab-link "furnace.alloy" } " vocabulary for an easy way of doing this." } }
} ;

ARTICLE: "furnace.sessions.serialize" "Session state serialization"
"Session variable values are serialized to the database using the " { $link "serialize" } " library."
$nl
"This means that there are three restrictions on the values stored in the session:"
{ $list
    "Continuations cannot be stored at all."
    { "Object identity is not preserved between serialization and deserialization. That is, if an object is stored with " { $link sset } " and later retrieved with " { $link sget } ", the retrieved value will be " { $link = } " to the original, but not necessarily " { $link eq? } "." }
    { "All objects reachable from the value passed to " { $link sset } " are serialized, so large structures should not be stored in the session state, and neither should anything that can reference the global namespace. Large structures should be persisted in the database directly instead, using " { $vocab-link "db.tuples" } "." }
} ;

ARTICLE: "furnace.sessions" "Furnace sessions"
"The " { $vocab-link "furnace.sessions" } " vocabulary implements session management, which allows state to be maintained between HTTP requests. The session state is stored on the server; the client receives an opaque ID which is saved in a cookie (for GET requests) or a hidden form field (for POST requests)."
$nl
"To use session management, wrap your responder in an session manager:"
{ $subsections <sessions> }
"The sessions responder must be wrapped inside a database persistence responder (" { $link <db-persistence> } "). The " { $vocab-link "furnace.alloy" } " vocabulary combines all of these responders into one."
$nl
"Reading and writing session variables from a request:"
{ $subsections
    sget
    sset
    schange
}
"Additional topics:"
{ $subsections
    "furnace.sessions.config"
    "furnace.sessions.serialize"
} ;

ABOUT: "furnace.sessions"
