USING: help.markup help.syntax strings ;
IN: furnace.auth.providers

HELP: user
{ $class-description "The class of users. Instances have the following slots:"
{ $table
    { { $slot "username" } { "The username, used to identify the user for login purposes" } }
    { { $slot "realname" } { "The user's real name, optional" } }
    { { $slot "password" } { "The user's password, encoded with a checksum" } }
    { { $slot "salt" } { "A random salt prepended to the password to ensure that two users with the same plain-text password still have different checksum output" } }
    { { $slot "email" } { "The user's e-mail address, optional" } }
    { { $slot "ticket" } { "Used for password recovery" } }
    { { $slot "capabilities" } { "A sequence of capabilities; see " { $link "furnace.auth.capabilities" } } }
    { { $slot "profile" } { "A hashtable with webapp-specific configuration" } }
    { { $slot "deleted" } { "A boolean indicating whether the user is active or not. This allows a user account to be deactivated without removing the user from the database" } }
    { { $slot "changed?" } { "A boolean indicating whether the user has changed since being retrieved from the database" } }
} } ;

HELP: add-user
{ $values { "provider" "an authentication provider" } { "user" user } }
{ $description "A utility word which calls " { $link new-user } " and throws an error if the user already exists." } ;

HELP: get-user
{ $values { "username" string } { "provider" "an authentication provider" } { "user/f" { $maybe user } } }
{ $contract "Looks up a username in the authentication provider." } ;

HELP: new-user
{ $values { "user" user } { "provider" "an authentication provider" } { "user/f" { $maybe user } } }
{ $contract "Adds a new user to the authentication provider. Outputs " { $link f } " if a user with this username already exists." } ;

HELP: update-user
{ $values { "user" user } { "provider" "an authentication provider" } }
{ $contract "Stores a user back to an authentication provider after being changed. This is a no-op with in-memory providers; providers which use an external store will save the user in this word. " } ;

ARTICLE: "furnace.auth.providers.protocol" "Authentication provider protocol"
"The " { $vocab-link "furnace.auth.providers" } " vocabulary implements a protocol for persistence and authentication of users."
$nl
"The class of users:"
{ $subsections user }
"Generic protocol:"
{ $subsections
    get-user
    new-user
    update-user
} ;

ABOUT: "furnace.auth.providers.protocol"
