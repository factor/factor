USING: help.markup help.syntax ;
IN: furnace.auth.providers.null

HELP: no-users
{ $class-description "Singleton class implementing the dummy authentication provider." } ;

ARTICLE: "furnace.auth.providers.null" "Dummy authentication provider"
"The " { $vocab-link "furnace.auth.providers.null" } " vocabulary implements an authentication provider which refuses all authentication requests. It is only useful for testing purposes." ;

ABOUT: "furnace.auth.providers.null"
