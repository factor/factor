USING: help.markup help.syntax io.backend io.files io.directories strings
sequences io.pathnames.private ;
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

HELP: file-extension
{ $values { "path" "a pathname string" } { "extension" string } }
{ $description "Outputs the extension of " { $snippet "path" } ", or " { $link f } " if the filename has no extension." }
{ $examples
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/bin/gcc\" file-extension ." "f" }
    { $example "USING: io.pathnames prettyprint ;" "\"/home/csi/gui.vbs\" file-extension ." "\"vbs\"" }
} ;

HELP: file-stem
{ $values { "path" "a pathname string" } { "stem" string } }
{ $description "Outputs the " { $link file-name } " of " { $snippet "filename" } " with the file extension removed, if any." }
{ $examples
    { $example "USING: io.pathnames prettyprint ;" "\"/usr/bin/gcc\" file-stem ." "\"gcc\"" }
    { $example "USING: io.pathnames prettyprint ;" "\"/home/csi/gui.vbs\" file-stem ." "\"gui\"" }
} ;

{ file-name file-stem file-extension } related-words

HELP: path-components
{ $values { "path" "a pathnames string" } { "seq" sequence } }
{ $description "Splits a pathname on the " { $link path-separator } " into its its component strings." } ;

HELP: append-path
{ $values { "path1" "a pathname string" } { "path2" "a pathname string" } { "path" "a pathname string" } }
{ $description "Appends " { $snippet "path1" } " and " { $snippet "path2" } " to form a pathname." }
{ $examples
    { $unchecked-example """USING: io.pathnames prettyprint ;
"first" "second.txt" append-path ."""
"first/second.txt"
    }
} ;

HELP: prepend-path
{ $values { "path1" "a pathname string" } { "path2" "a pathname string" } { "path" "a pathname string" } }
{ $description "Appends " { $snippet "path2" } " and " { $snippet "path1" } " to form a pathname." }
{ $examples
    { $unchecked-example """USING: io.pathnames prettyprint ;
"second.txt" "first" prepend-path ."""
"first/second.txt"
    }
} ;

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
{ $values { "string" "a pathname string" } { "string'" "a new pathname string" } }
{ $description "Prepends the " { $link current-directory } " to the pathname, resolves a " { $snippet "resource:" } " or " { $snippet "voacb:" } " prefix, if present, and performs any platform-specific pathname normalization." }
{ $notes "High-level words, such as " { $link <file-reader> } " and " { $link delete-file } " call this word for you. It only needs to be called directly when passing pathnames to C functions or external processes. This is because Factor does not use the operating system's notion of a current directory, and instead maintains its own dynamically-scoped " { $link current-directory } " variable." }
{ $notes "On Windows NT platforms, this word does prepends the Unicode path prefix." }
{ $examples
  "For example, if you create a file named " { $snippet "data.txt" } " in the current directory, and wish to pass it to a process, you must normalize it:"
  { $code
    "\"1 2 3\" \"data.txt\" ascii set-file-contents"
    "\"munge\" \"data.txt\" normalize-path 2array run-process"
  }
} ;

HELP: (normalize-path)
{ $values
    { "path" "a pathname string" }
    { "path'" "a pathname string" }
}
{ $description "Prepends the " { $link current-directory } " to the pathname and resolves a " { $snippet "resource:" } " prefix, if present." }
{ $notes "On Windows NT platforms, this word does not prepend the Unicode path prefix." } ;

HELP: canonicalize-path
{ $values { "path" "a pathname string" } { "path'" "a new pathname string" } }
{ $description "Outputs a path where none of the path components are symlinks. This word is useful for determining the actual path on disk where a file is stored; the root of this absolute path is a mount point in the file-system." }
{ $notes "Most code should not need to call this word except in very special circumstances. One use case is finding the actual file-system on which a file is stored." } ;

HELP: <pathname>
{ $values { "string" "a pathname string" } { "pathname" pathname } }
{ $description "Creates a new " { $link pathname } "." } ;

HELP: home
{ $values { "dir" string } }
{ $description "Outputs the user's home directory." }
{ $examples
    { $unchecked-example "USING: io.pathnames prettyprint ;"
                "home ."
                "/home/factor-user"
    }
} ;

ARTICLE: "io.pathnames" "Pathnames"
"Pathnames are objects that contain a string representing the path to a file on disk. Pathnames are cross-platform; Windows accepts both forward and backward slashes as directory separators and new separators are added as a forward slash on all platforms. Clicking a pathname object in the UI brings up the file in one of the supported editors, but otherwise, pathnames and strings are interchangeable. See " { $link "editor" } " for more details." $nl
"Pathname introspection:"
{ $subsections
    parent-directory
    file-name
    file-stem
    file-extension
    path-components
}
"Appending pathnames:"
{ $subsections
    prepend-path
    append-path
}
"Pathname presentations:"
{ $subsections
    pathname
    <pathname>
}
"Literal pathnames:"
{ $subsections POSTPONE: P" }
"Low-level words:"
{ $subsections
    normalize-path
    (normalize-path)
    canonicalize-path
} ;

ABOUT: "io.pathnames"
