USING: help.markup help.syntax ;
IN: furnace.auth.providers.assoc

HELP: <users-in-memory>
{ $values { "provider" users-in-memory } }
{ $description "Creates a new authentication provider which stores the usernames and passwords in an associative mapping." } ;

ARTICLE: "furnace.auth.providers.assoc" "In-memory authentication provider"
"The " { $vocab-link "furnace.auth.providers.assoc" } " vocabulary implements an authentication provider which looks up usernames and passwords in an associative mapping."
{ $subsections
    users-in-memory
    <users-in-memory>
}
"The " { $slot "assoc" } " slot of the " { $link users-in-memory } " tuple maps usernames to checksums of passwords." ;

ABOUT: "furnace.auth.providers.assoc"
