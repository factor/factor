USING: help.markup help.syntax strings ;
IN: furnace.auth.login

HELP: <login-realm>
{ $values
    { "responder" "a responder" } { "name" string }
    { "realm" "a new responder" }
}
{ $description "Wraps a responder in a new login realm with the given name. The realm must be configured before use; see " { $link "furnace.auth.realm-config" } "." } ;

HELP: login-realm
{ $class-description "The login realm class. Slots are described in " { $link "furnace.auth.realm-config" } "." } ;

ARTICLE: "furnace.auth.login" "Login authentication"
"The " { $vocab-link "furnace.auth.login" } " vocabulary implements an authentication realm which displays a login page with a username and password field."
{ $subsections
    login-realm
    <login-realm>
}
"The " { $snippet "logout" } " action logs the user out of the realm, and a link to this action can be inserted in Chloe templates using the following XML snippet:"
{ $code
    "<t:button t:action=\"$login-realm/logout\">Logout</t:button>"
} ;

ABOUT: "furnace.auth.login"
