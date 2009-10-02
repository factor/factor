! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string kernel quotations sequences strings math ;
IN: unix.groups

HELP: all-groups
{ $values { "seq" sequence } }
{ $description "Returns a sequence of " { $link group } " tuples that are platform-dependent and field for field complete with the Unix " { $link group } " structure." } ;

HELP: effective-group-id
{ $values { "string" string } }
{ $description "Returns the effective group id for the current user." } ;

HELP: effective-group-name
{ $values { "string" string } }
{ $description "Returns the effective group name for the current user." } ;

HELP: group
{ $description "A platform-specific tuple corresponding to every field from the Unix group struct including the group name, the group id, the group passwd, and a list of users in each group." } ;

HELP: group-cache
{ $description "A symbol containing a cache of groups returned from " { $link all-groups } " and indexed by group id. Can be more efficient than using the system call words for many group lookups." } ;

HELP: group-id
{ $values
     { "string" string }
     { "id/f" "an integer or f" } }
{ $description "Returns the group id given a group name. Returns " { $link f } " if the group does not exist." } ;

HELP: group-name
{ $values
     { "id" integer }
     { "string" string } }
{ $description "Returns the group name given a group id." } ;

HELP: group-struct
{ $values
     { "obj" object }
     { "group/f" "a group struct or f" } }
{ $description "Returns an alien group struct to be turned into a group tuple by calling subsequent words." } ;

HELP: real-group-id
{ $values { "id" integer } }
{ $description "Returns the real group id for the current user." } ;

HELP: real-group-name
{ $values { "string" string } }
{ $description "Returns the real group name for the current user." } ;

HELP: set-effective-group
{ $values
     { "obj" object } }
{ $description "Sets the effective group id for the current user." } ;

HELP: set-real-group
{ $values
     { "obj" object } }
{ $description "Sets the real group id for the current user." } ;

HELP: user-groups
{ $values
     { "string/id" "a string or a group id" }
     { "seq" sequence } }
{ $description "Returns the sequence of groups to which the user belongs." } ;

HELP: with-effective-group
{ $values
     { "string/id" "a string or a group id" } { "quot" quotation } }
{ $description "Sets the effective group name and calls the quotation. Restors the effective group name on success or on error after the call." } ;

HELP: with-group-cache
{ $values
     { "quot" quotation } }
{ $description "Iterates over the group file using library calls and creates a cache in the " { $link group-cache } " symbol. The cache is a hashtable indexed by group id. When looking up many groups, this approach is much faster than calling system calls." } ;

HELP: with-real-group
{ $values
     { "string/id" "a string or a group id" } { "quot" quotation } }
{ $description "Sets the real group name and calls the quotation. Restores the current group name on success or on error after the call." } ;

ARTICLE: "unix.groups" "Unix groups"
"The " { $vocab-link "unix.groups" } " vocabulary contains words that return information about Unix groups."
$nl
"Listing all groups:"
{ $subsections all-groups }
"Real groups:"
{ $subsections
    real-group-name
    real-group-id
    set-real-group
}
"Effective groups:"
{ $subsections
    effective-group-name
    effective-group-id
    set-effective-group
}
"Combinators to change groups:"
{ $subsections
    with-real-group
    with-effective-group
} ;

ABOUT: "unix.groups"
