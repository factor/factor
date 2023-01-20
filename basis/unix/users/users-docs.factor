! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string kernel quotations sequences strings math ;
IN: unix.users

HELP: all-users
{ $values { "seq" sequence } }
{ $description "Returns a sequence of high-level " { $link passwd } " tuples that are platform-dependent and field for field complete with the Unix " { $link passwd } " structure." } ;

HELP: effective-user-name
{ $values { "string" string } }
{ $description "Returns the effective user-name for the current user." } ;

HELP: effective-user-id
{ $values { "id" integer } }
{ $description "Returns the effective user-name id for the current user." } ;

HELP: new-passwd
{ $values { "passwd" passwd } }
{ $description "Creates a new passwd tuple dependent on the operating system." } ;

HELP: passwd
{ $description "A platform-specific tuple corresponding to every field from the Unix passwd struct. BSD passwd structures have four extra slots: " { $snippet "change" } ", " { $snippet "class" } ", " { $snippet "expire" } ", " { $snippet "fields" } "." } ;

HELP: user-cache
{ $description "A symbol storing passwd structures indexed by user-ids when within a " { $link with-user-cache } "." } ;

HELP: passwd>new-passwd
{ $values
    { "passwd" "a passwd struct" }
    { "new-passwd" "a passwd tuple" } }
{ $description "A platform-specific conversion routine from a passwd structure to a passwd tuple." } ;

HELP: real-user-name
{ $values { "string" string } }
{ $description "The real user-name of the current user." } ;

HELP: real-user-id
{ $values { "id" integer } }
{ $description "The real user id of the current user." } ;

HELP: set-effective-user
{ $values { "string/id" "a string or a user id" } }
{ $description "Sets the current effective user given a user-name or a user id." } ;

HELP: set-real-user
{ $values { "string/id" "a string or a user id" } }
{ $description "Sets the current real user given a user-name or a user id." } ;

HELP: user-passwd
{ $values
    { "obj" object }
    { "passwd/f" "passwd or f" } }
{ $description "Returns the passwd tuple given a user-name string or user id." } ;

HELP: user-name
{ $values
    { "id" integer }
    { "string" string } }
{ $description "Returns the user-name associated with the user id." } ;

HELP: user-id
{ $values
    { "string" string }
    { "id/f" "an integer or f" } }
{ $description "Returns the user id associated with the user-name." } ;

HELP: with-effective-user
{ $values
    { "string/id/f" "a string, a uid, or f" } { "quot" quotation } }
{ $description "Sets the effective user-name and calls the quotation. Restores the current user-name on success or on error after the call. If the first parameter is " { $link f } ", the quotation is called as the current user." } ;

HELP: with-user-cache
{ $values
    { "quot" quotation } }
{ $description "Iterates over the password file using library calls and creates a cache in the " { $link user-cache } " symbol. The cache is a hashtable indexed by user id. When looking up many users, this approach is much faster than calling system calls." } ;

HELP: with-real-user
{ $values
    { "string/id/f" "a string, a uid, or f" } { "quot" quotation } }
{ $description "Sets the real user-name and calls the quotation. Restores the current user-name on success or on error after the call. If the first parameter is " { $link f } ", the quotation is called as the current user." } ;

{
    real-user-name real-user-id set-real-user
    effective-user-name effective-user-id
    set-effective-user
} related-words

HELP: ?user-id
{ $values
    { "string" string }
    { "id/f" "an integer or " { $link f } }
}
{ $description "Returns a group id or throws an exception." } ;

HELP: all-user-names
{ $values

    { "seq" sequence }
}
{ $description "Returns a sequence of group names as strings." } ;

HELP: user-exists?
{ $values
    { "name/id" "a string or an integer" }
    { "?" boolean }
}
{ $description "Returns a boolean representing the user's existence." } ;

ARTICLE: "unix.users" "Unix users"
"The " { $vocab-link "unix.users" } " vocabulary contains words that return information about Unix users."
$nl
"Listing all users:"
{ $subsections all-users }
"Listing all user names:"
{ $subsections all-user-names }
"Checking if a user exists:"
{ $subsections user-exists? }
"Querying/setting the current real user:"
{ $subsections
    real-user-name
    real-user-id
    set-real-user
}
"Querying/setting the current effective user:"
{ $subsections
    effective-user-name
    effective-user-id
    set-effective-user
}
"Combinators to change users:"
{ $subsections
    with-real-user
    with-effective-user
} ;

ABOUT: "unix.users"
