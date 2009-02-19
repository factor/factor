USING: help.markup help.syntax io.backend io.files strings
sequences ;
IN: io.pathnames

HELP: path-separator?
{ $values { "ch" "a code point" } { "?" "a boolean" } }
{ $description "Tests if the code point is a platform-specific path separator." }
{ $examples
    "On Unix:"
    { $example "USING: io.pathnames prettyprint ;" "CHAR: / path-separator? ." "t" }
} ;

HELP: parent-directory
{ $values { "path" "a pathname string" } { "parent" "a pathname string" } }
{ $description "Strips the last component off a pathname." }
{ $examples { $example "USING: io io.pathnames ;" "\"/etc/passwd\" parent-directory print" "/etc/" } } ;

HELP: file-name
{ $values { "path" "a pathname string" } { "string" string } }
{ $description "Outputs the last component of a pathname string." }
{ $examples
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/bin/gcc\" file-name ." "\"gcc\"" }
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/libexec/awk/\" file-name ." "\"awk\"" }
} ;

HELP: path-components
{ $values { "path" "a pathnames string" } { "seq" sequence } }
{ $description "Splits a pathname on the " { $link path-separator } " into its its component strings." } ;

HELP: append-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Appends " { $snippet "str1" } " and " { $snippet "str2" } " to form a pathname." } ;

HELP: prepend-path
{ $values { "str1" "a string" } { "str2" "a string" } { "str" "a string" } }
{ $description "Appends " { $snippet "str2" } " and " { $snippet "str1" } " to form a pathname." } ;

{ append-path prepend-path } related-words

HELP: absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute. Examples of absolute pathnames are " { $snippet "/foo/bar" } " on Unix and " { $snippet "c:\\foo\\bar" } " on Windows." } ;

HELP: windows-absolute-path?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is absolute on Windows. Examples of absolute pathnames on Windows are " { $snippet "c:\\foo\\bar" } " and " { $snippet "\\\\?\\c:\\foo\\bar" } " for absolute Unicode pathnames." } ;

HELP: root-directory?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if a pathname is a root directory. Examples of root directory pathnames are " { $snippet "/" } " on Unix and " { $snippet "c:\\" } " on Windows." } ;

{ absolute-path? windows-absolute-path? root-directory? } related-words

HELP: resource-path
{ $values { "path" "a pathname string" } { "newpath" "a pathname string" } }
{ $description "Resolve a path relative to the Factor source code location." } ;

HELP: pathname
{ $class-description "Class of path name objects. Path name objects can be created by calling " { $link <pathname> } "." } ;

HELP: normalize-path
{ $values { "str" "a pathname string" } { "newstr" "a new pathname string" } }
{ $description "Called by words such as " { $link <file-reader> } " and " { $link <file-writer> } " to prepare a pathname before passing it to underlying code." } ;

HELP: canonicalize-path
{ $values { "path" "a pathname string" } { "path'" "a new pathname string" } }
{ $description "Returns an canonical name for a path. The canonical name is an absolute path containing no symlinks." } ;

HELP: <pathname>
{ $values { "string" "a pathname string" } { "pathname" pathname } }
{ $description "Creates a new " { $link pathname } "." } ;

HELP: home
{ $values { "dir" string } }
{ $description "Outputs the user's home directory." } ;

ARTICLE: "pathname-normalization" "Pathname normalization"
"Words that take a pathname should normalize the pathname by calling " { $link normalize-path } ".When normalizing a pathname, the input pathname is either absolute or relative to the " { $link current-directory } ". If absolute, such as the root directories " { $snippet "/" } " or " { $snippet "c:\\" } ", the pathname is left alone, while if relative, the current directory is prepended to the pathname. If a pathname begins with the magic string " { $snippet "resource:" } ", this string is replaced with the Factor directory. On Windows, all pathnames, absolute and relative, are converted to Unicode pathamess." ;

ARTICLE: "io.pathnames" "Pathname manipulation"
{ $subsection "pathname-normalization" }
"Literal pathnames:"
{ $subsection POSTPONE: P" }
"Pathname manipulation:"
{ $subsection normalize-path }
{ $subsection canonicalize-path }
{ $subsection parent-directory }
{ $subsection file-name }
{ $subsection last-path-separator }
{ $subsection path-components }
{ $subsection prepend-path }
{ $subsection append-path }
"Pathname presentations:"
{ $subsection pathname }
{ $subsection <pathname> } ;

ABOUT: "io.pathnames"
