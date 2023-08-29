! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar help.markup help.syntax io.files.info kernel
math strings ;
IN: io.files.info.unix

HELP: add-file-permissions
{ $values
    { "path" "a pathname string" }
    { "n" integer } }
{ $description "Ensures that the bits from " { $snippet "n" } " are set in the Unix file permissions for a given file." } ;

HELP: remove-file-permissions
{ $values
    { "path" "a pathname string" }
    { "n" integer } }
{ $description "Ensures that the bits from " { $snippet "n" } " are cleared in the Unix file permissions for a given file." } ;

HELP: file-group-id
{ $values
    { "path" "a pathname string" }
    { "gid" integer } }
{ $description "Returns the group id for a given file." } ;

HELP: file-group-name
{ $values
    { "path" "a pathname string" }
    { "string" string } }
{ $description "Returns the group name for a given file." } ;

HELP: file-permissions
{ $values
    { "path" "a pathname string" }
    { "n" integer } }
{ $description "Returns the Unix file permissions for a given file." } ;

HELP: file-user-name
{ $values
    { "path" "a pathname string" }
    { "string" string } }
{ $description "Returns the user-name for a given file." } ;

HELP: file-user-id
{ $values
    { "path" "a pathname string" }
    { "uid" integer } }
{ $description "Returns the user id for a given file." } ;

HELP: group-execute?
{ $values
    { "obj" "a pathname string or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "group execute" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: group-read?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "group read" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: group-write?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "group write" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: other-execute?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "other execute" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: other-read?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "other read" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: other-write?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "other write" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: set-file-access-time
{ $values
    { "path" "a pathname string" } { "timestamp" timestamp } }
{ $description "Sets a file's last access timestamp." } ;

HELP: set-file-group
{ $values
    { "path" "a pathname string" } { "string/id" "a string or a group id" } }
{ $description "Sets a file's group id from the given group id or group name." } ;

HELP: set-file-ids
{ $values
    { "path" "a pathname string" } { "uid" integer } { "gid" integer } }
{ $description "Sets the user id and group id of a file with a single library call." } ;

HELP: set-file-permissions
{ $values
    { "path" "a pathname string" } { "n" "an integer, interpreted as a string of bits" } }
{ $description "Sets the file permissions for a given file with the supplied Unix permissions integer." }
{ $examples "Using the traditional octal value:"
    { $code "USING: io.files.info.unix kernel ;"
        "\"resource:LICENSE.txt\" 0o755 set-file-permissions"
    }
    "Higher-level, setting named bits:"
    { $code "USING: io.files.info.unix kernel literals ;"
    "\"resource:LICENSE.txt\""
    "flags{ USER-ALL GROUP-READ GROUP-EXECUTE OTHER-READ OTHER-EXECUTE }"
    "set-file-permissions"
    }
} ;

HELP: set-file-times
{ $values
    { "path" "a pathname string" } { "timestamps" "an array of two timestamps" } }
{ $description "Sets the access and write timestamps for a file as provided in the input array. A value of " { $link f } " provided for either of the timestamps will not change that timestamp." } ;

HELP: set-file-user
{ $values
    { "path" "a pathname string" } { "string/id" "a string or a user id" } }
{ $description "Sets a file's user id from the given user id or user-name." } ;

HELP: set-file-modified-time
{ $values
    { "path" "a pathname string" } { "timestamp" timestamp } }
{ $description "Sets a file's last modified timestamp, or write timestamp." } ;

HELP: set-gid
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "gid" } " bit of a file to true or false." } ;

HELP: gid?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "gid" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: set-group-execute
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "group execute" } " bit of a file to true or false." } ;

HELP: set-group-read
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "group read" } " bit of a file to true or false." } ;

HELP: set-group-write
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "group write" } " bit of a file to true or false." } ;

HELP: set-other-execute
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "other execute" } " bit of a file to true or false." } ;

HELP: set-other-read
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "other read" } " bit of a file to true or false." } ;

HELP: set-other-write
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "other execute" } " bit of a file to true or false." } ;

HELP: set-sticky
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "sticky" } " bit of a file to true or false." } ;

HELP: sticky?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "sticky" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: set-uid
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "uid" } " bit of a file to true or false." } ;

HELP: uid?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "uid" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: set-user-execute
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "user execute" } " bit of a file to true or false." } ;

HELP: set-user-read
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "user read" } " bit of a file to true or false." } ;

HELP: set-user-write
{ $values
    { "path" "a pathname string" } { "?" boolean } }
{ $description "Sets the " { $snippet "user write" } " bit of a file to true or false." } ;

HELP: user-execute?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "user execute" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: user-read?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "user read" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

HELP: user-write?
{ $values
    { "obj" "a pathname string, file-info object, or an integer" }
    { "?" boolean } }
{ $description "Tests whether the " { $snippet "user write" } " bit is set on a file, " { $link file-info } ", or an integer." } ;

ARTICLE: "unix-file-permissions" "Unix file permissions"
"Reading all file permissions:"
{ $subsections file-permissions }
"Reading individual file permissions:"
{ $subsections
    uid?
    gid?
    sticky?
    user-read?
    user-write?
    user-execute?
    group-read?
    group-write?
    group-execute?
    other-read?
    other-write?
    other-execute?
}
"Changing file permissions:"
{ $subsections
    add-file-permissions
    remove-file-permissions
    set-file-permissions
}
"Writing individual file permissions:"
{ $subsections
    set-uid
    set-gid
    set-sticky
    set-user-read
    set-user-write
    set-user-execute
    set-group-read
    set-group-write
    set-group-execute
    set-other-read
    set-other-write
    set-other-execute
} ;

ARTICLE: "unix-file-timestamps" "Unix file timestamps"
"To read file times, use the accessors on the object returned by the " { $link file-info } " word." $nl
"Setting multiple file times:"
{ $subsections set-file-times }
"Setting just the last access time:"
{ $subsections set-file-access-time }
"Setting just the last modified time:"
{ $subsections set-file-modified-time } ;


ARTICLE: "unix-file-ids" "Unix file user and group ids"
"Reading file user data:"
{ $subsections
    file-user-id
    file-user-name
}
"Setting file user data:"
{ $subsections set-file-user }
"Reading file group data:"
{ $subsections
    file-group-id
    file-group-name
}
"Setting file group data:"
{ $subsections set-file-group } ;


ARTICLE: "io.files.info.unix" "Unix file attributes"
"The " { $vocab-link "io.files.info.unix" } " vocabulary implements a high-level way to set Unix-specific permissions, timestamps, and user and group IDs for files."
{ $subsections
    "unix-file-permissions"
    "unix-file-timestamps"
    "unix-file-ids"
} ;

ABOUT: "io.files.info.unix"
