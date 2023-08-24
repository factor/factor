USING: furnace.db furnace.redirection furnace.sessions
help.markup help.syntax http urls ;
IN: furnace.asides

HELP: <asides>
{ $values
    { "responder" "a responder" }
    { "responder'" "a new responder" }
}
{ $description "Creates a new " { $link asides } " responder wrapping an existing responder." } ;

HELP: begin-aside
{ $values { "url" url } }
{ $description "Begins an aside. When the current action returns a " { $link <redirect> } ", the redirect will have query parameters which reference the current page via an opaque handle." } ;

HELP: end-aside
{ $values { "default" url } { "response" response } }
{ $description "Ends an aside. If an aside is currently active, the response redirects the client " } ;

ARTICLE: "furnace.asides" "Furnace asides"
"The " { $vocab-link "furnace.asides" } " vocabulary provides support for sending a user to a page which can then return to the former location."
$nl
"To use asides, wrap your responder in an aside responder:"
{ $subsections <asides> }
"The asides responder must be wrapped inside a session responder (" { $link <sessions> } "), which in turn must be wrapped inside a database persistence responder (" { $link <db-persistence> } "). The " { $vocab-link "furnace.alloy" } " vocabulary combines all of these responders into one."
$nl
"Saving the current page in an aside which propagates through " { $link <redirect> } " responses:"
{ $subsections begin-aside }
"Returning from an aside:"
{ $subsections end-aside }
"Asides are used by " { $vocab-link "furnace.auth.login" } "; when the client requests a protected page, an aside begins and the client is redirected to a login page. Upon a successful login, the aside ends and the client returns to the protected page. If the client directly visits the login page and logs in, there is no current aside, so the client is sent to the default URL passed to " { $link end-aside } ", which in the case of login is the root URL." ;

ABOUT: "furnace.asides"
