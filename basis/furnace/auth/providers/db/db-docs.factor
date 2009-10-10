USING: help.markup help.syntax ;
IN: furnace.auth.providers.db

HELP: users-in-db
{ $class-description "Singleton class implementing the database authentication provider." } ;

ARTICLE: "furnace.auth.providers.db" "Database authentication provider"
"The " { $vocab-link "furnace.auth.providers.db" } " vocabulary implements an authentication provider which looks up authentication requests in the " { $snippet "USERS" } " table of the current database. The database schema is Factor-specific, and the table should be initialized by calling"
{ $code "users create-table" }
"The authentication provider class:"
{ $subsections users-in-db } ;

ABOUT: "furnace.auth.providers.db"
