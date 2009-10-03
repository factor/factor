USING: help.markup help.syntax arrays io.files ;
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
{ $description "Returns a platform-specific object describing the file-system that contains the path. The cross-platform slot is " { $slot "free-space" } "." } ;

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
} ;

ABOUT: "io.files.info"
