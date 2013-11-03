USING: help.markup help.syntax db strings ;
IN: webapps.user-admin

HELP: <user-admin>
{ $values { "responder" "a new responder" } }
{ $description "Creates a new instance of the user admin tool. This tool must be added to an authentication realm, and access is restricted to users having the " { $link can-administer-users? } " capability." } ;

HELP: can-administer-users?
{ $description "A user capability. Users having this capability may use the " { $link user-admin } " tool." }
{ $notes "See " { $link "furnace.auth.capabilities" } " for information about capabilities." } ;

HELP: make-admin
{ $values { "username" string } }
{ $description "Makes an existing user into an administrator by giving them the " { $link can-administer-users? } " capability, thus allowing them to use the user admin tool." } ;

ARTICLE: "webapps.user-admin" "Furnace user administration tool"
"The " { $vocab-link "webapps.user-admin" } " vocabulary implements a web application for adding, removing and editing users in authentication realms that use " { $link "furnace.auth.providers.db" } "."
{ $subsections <user-admin> }
"Access to the web app itself is protected, and only users having an administrative capability can access it:"
{ $subsections can-administer-users? }
"To make an existing user an administrator, call the following word in a " { $link with-db } " scope:"
{ $subsections make-admin } ;
