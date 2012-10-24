USING: arrays help.markup help.syntax kernel io.files ;
IN: io.files.info

HELP: file-info
{ $values { "path" "a pathname string" } { "info" file-info } }
{ $description "Queries the file system for metadata. If " { $snippet "path" } " refers to a symbolic link, it is followed. See the article " { $link "file-types" } " for a list of metadata symbols." }
{ $errors "Throws an error if the file does not exist." } ;

HELP: link-info
{ $values { "path" "a pathname string" } { "info" "a file-info tuple" } }
{ $description "Queries the file system for metadata. If path refers to a symbolic link, information about the symbolic link itself is returned. If the file does not exist, an exception is thrown." } ;

{ file-info link-info } related-words

HELP: directory?
{ $values { "file-info" file-info } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "file-info" } " is a directory." } ;

HELP: file-systems
{ $values { "array" array } }
{ $description "Returns an array of " { $link file-system-info } " objects returned by iterating the mount points and calling " { $link file-system-info } " on each." } ;

HELP: file-system-info
{ $values
{ "path" "a pathname string" }
{ "file-system-info" file-system-info } }
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
{ $description "Returns whether the file specified by " { $snippet "path" } " exists and is readable by the current process." } ;

HELP: file-writable?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Returns whether the file specified by " { $snippet "path" } " exists and is writable by the current process." } ;

HELP: file-executable?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Returns whether the file specified by " { $snippet "path" } " exists and is executable by the current process." } ;

ARTICLE: "io.files.info" "File system meta-data"
"File meta-data:"
{ $subsections
    file-info
    link-info
    exists?
    directory?
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
