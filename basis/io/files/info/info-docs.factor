USING: arrays help.markup help.syntax kernel io.files ;
IN: io.files.info

HELP: file-info
{ $values { "path" "a pathname string" } { "info" file-info-tuple } }
{ $description "Queries the file system for metadata. If " { $snippet "path" } " refers to a symbolic link, it is followed. See the article " { $link "file-types" } " for a list of metadata symbols." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: link-info
{ $values { "path" "a pathname string" } { "info" file-info-tuple } }
{ $description "Queries the file system for metadata. If " { $snippet "path" } " refers to a symbolic link, information about the symbolic link itself is returned. See the article " { $link "file-types" } " for a list of metadata symbols." }
{ $errors "Throws an error if the file does not exist." } ;

{ file-info link-info file-info-tuple } related-words

HELP: directory?
{ $values { "file-info" file-info-tuple } { "?" boolean } }
{ $description "Tests if " { $snippet "file-info" } " is a directory." } ;

HELP: regular-file?
{ $values { "file-info" file-info-tuple } { "?" boolean } }
{ $description "Tests if " { $snippet "file-info" } " is a normal file." } ;

HELP: symbolic-link?
{ $values { "file-info" file-info-tuple } { "?" boolean } }
{ $description "Tests if " { $snippet "file-info" } " is a symbolic link." } ;

HELP: file-systems
{ $values { "array" array } }
{ $description "Returns an array of " { $link file-system-info } " objects returned by iterating the mount points and calling " { $link file-system-info } " on each." }
{ $notes "File systems that the process doesn't have access to aren't included." } ;

HELP: file-system-info
{ $values
{ "path" "a pathname string" }
{ "file-system-info" file-system-info-tuple } }
{ $description "Returns a platform-specific object describing the file-system that contains the path. The cross-platform slot is " { $slot "free-space" } "." }
{ $examples
    { $unchecked-example
        "USING: io.files.info io.pathnames math prettyprint ;"
        "IN: scratchpad"
        ""
        ": gb ( m -- n ) 30 2^ * ;"
        ""
        "home file-system-info free-space>> 100 gb < ."
        "f"
    }
} ;

HELP: file-readable?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Returns whether the file specified by " { $snippet "path" } " is readable by the current process." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: file-writable?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Returns whether the file specified by " { $snippet "path" } " is writable by the current process." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: file-executable?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Returns whether the file specified by " { $snippet "path" } " is executable by the current process." }
{ $errors "Throws an error if the file does not exist." } ;

ARTICLE: "io.files.info" "File system meta-data"
"File meta-data:"
{ $subsections
    file-info
    link-info
    exists?
    directory?
    regular-file?
    symbolic-link?
}
"File types:"
{ $subsections "file-types" }
"File system meta-data:"
{ $subsections
    file-system-info
    file-systems
}
"File permissions:"
{ $subsections
    file-readable?
    file-writable?
    file-executable?
} ;

ABOUT: "io.files.info"
