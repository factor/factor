USING: help.markup help.syntax ;
IN: furnace.auth.basic

HELP: <basic-auth-realm>
{ $values { "responder" "a responder" } { "name" "an authentication realm name" } { "realm" basic-auth-realm } }
{ $description "Wraps a responder in a basic authentication realm." } ;

ARTICLE: "furnace.auth.basic" "Basic authentication"
"The " { $vocab-link "furnace.auth.basic" } " vocabulary implements HTTP basic authentication."
{ $subsection <basic-auth-realm> } ;

ABOUT: "furnace.auth.basic"
