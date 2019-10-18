USING: help.markup help.syntax ;
IN: furnace.auth.basic

HELP: <basic-auth-realm>
{ $values { "responder" "a responder" } { "name" "an authentication realm name" } { "realm" basic-auth-realm } }
{ $description "Wraps a responder in a basic authentication realm. The realm must be configured before use; see " { $link "furnace.auth.realm-config" } "." } ;

HELP: basic-auth-realm
{ $class-description "The basic authentication realm class. Slots are described in " { $link "furnace.auth.realm-config" } "." } ;

ARTICLE: "furnace.auth.basic" "Basic authentication"
"The " { $vocab-link "furnace.auth.basic" } " vocabulary implements HTTP basic authentication."
{ $subsections
    basic-auth-realm
    <basic-auth-realm>
} ;

ABOUT: "furnace.auth.basic"
