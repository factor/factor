! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax images io.backend io.directories
io.files.types kernel quotations sequences strings ;


IN: io.pathnames
HELP: space?
{ $values { "ch" "character to compare" } { "?" "truth value" } }
{ $description "Compares character with space" }
;

HELP: tab?
{ $values { "ch" "character to compare" } { "?" "truth value" } }
{ $description "Compares character with tab" }
;

HELP: components-to-path 
{ $values 
  { "seq" "sequence of path names" } 
  { "path" "completed path" } 
}
{ $description "Given a sequence of path components, will join them together into a complete path" }
;

HELP: bump-name
{ $values
  { "path" string }
  { "path'" string }
}
{ $description "Detects if the directory entry at path exists, and if so, adds a numbered"
  " extension to its name. If the the entry already has a numbered extension, the value"
  " is incremented and the check repeated until a unique file name is discovered."
  " Used by " { $link move-aside } " to save a file in place before a file operation occurs."
}
{ $notes
  {
      "If the entry " { $snippet "file" } " exists the name returned will be " { $snippet "file.1" } 
      " If the entry " { $snippet "file.1" } " exists the name returned will be " { $snippet "file.2" }
      " Note that if an entry contains a name representing a version, as in AnApp-1.2.3, the trailing"
      " value will be incremented."
  }
}
;

IN: folder

HELP: (directory-entries)
{ $values
    { "path" string }
    { "seq" sequence }
}
{ $description "Returns all of the items of a directory as folder entries given a"
  " a pathname as a string. Typically, you would normally use " { $link directory-entries }
  " to filter out the current and parent directories."
}
;

HELP: <folder-entry>
{ $values
  { "name" string } { "type" { $link "file-types"  } } { "path" string }
    { "folder" folder-entry }
}
  { $description "Creates a folder-entry with the name, type, and path." }
{ $examples
    "Create a folder-entry for your home Desktop:"
    { $code
      "USING: folder ;"
      "\"Desktop\" +directory+ \"/Users/home\" <folder-entry>"
    }
  }
;

HELP: directory-entries
{ $values
    { "path" string }
    { "seq" sequence }
}
{ $description "Returns all of the items of a directory as folder entries given a"
  " a pathname as a string. Use " { $link (directory-entries) }
  " to include the current and parent directories."  
} ;

HELP: directory-files
{ $values
    { "path" "a pathname string" }
    { "seq" sequence }
}
{ $description "" } ;

HELP: folder-entry
{ $var-description "" } ;

HELP: pathname
{ $values
    { "folder" null }
    { "path" "a pathname string" }
}
{ $description "" } ;

HELP: with-directory-entries
{ $values
    { "path" "a pathname string" } { "quot" quotation }    
}
{ $description "" } ;

HELP: with-directory-files
{ $values
    { "path" "a pathname string" } { "quot" quotation }    
}
{ $description "" } ;

ARTICLE: "folder" "Folders"
"The " { $vocab-link "folder-entry" }
" vocabulary is a subclass of " { $snippet "directory-entry" } " in "
{ $vocab-link "io.directories" }  ". 

A folder-entry contains the additional slot "
{ $slot "path" }
" as a full path to an entry. It is intended for use when the pathname is needed for more"
" complex operations on folders and files. The vocabulary contains words matching the usage"
" found in io.directories but works with folder entries instead of directory entries."
$nl
{ $subsections
    "cookbook"
    "help-impl"
} ;


ABOUT: "folder"

HELP: as-directory
{ $values { "path" string } { "path'" string } }
{ $description "Returns a given as a directory path. A trailing / is added if needed" }
{ $examples
  { $code 
        "/Applications as-directory"
    ""
    "--- Data stack:"
    "/Applications/"
    }
}
;

HELP: special-path?
{ $values { "path" string } { "rest" string } { "?" boolean } }
{ $description "Determines if a path is special, e.g. begins with resource: vocab: or ~" }
{ $examples
  { $code 
    "\"~/Desktop\" special?"
    ""
    "--- Data stack:"
    "\"/Desktop\""
    "t"
    ""
  }
}
{ $notes "No Notes" }
;

HELP: as-file
{ $values { "path" pathname } { "path'" pathname } }
{ $description "Converts path to file, strips any trailing /" }
{ $examples
  { $code
    "USING: folder ;"
    "\"/Applications/iTunes.app/\" as-file"
  }
}
;

HELP: (empty-to-root)
{ $values { "path" string } { "path'" string } }
{ $description "Converts an empty string (given as a path) into the root path \ " }
;

! HELP: (homepath)
! { $values { "path" string } { "newpath" string } }
! { $description "Prefixes the user home path to a path" }
! { $notes "Used to expand a ~ in a path to a user home folder e.g. ~davec/path becomes "
! " /Users/davec/path"
! }
! ;

IN: io.pathnames-docs
HELP: absolute-path
{ $values
    { "path" "a pathname string" }
    { "path'" "a pathname string" }
}
{ $description "Prepends the " { $link current-directory } " to the pathname and resolves a "
  { $snippet "resource:" } ", " { $snippet "~" } " or " { $snippet "~user" }
  " or " { $snippet "vocab:" }
  " prefix, if present (see " { $link "io.pathnames.special" } ")." }
{ $notes "This word is exactly the same as " { $link normalize-path } ", except on Windows NT platforms, where it does not prepend the Unicode path prefix. Most code should call " { $link normalize-path } " instead." } ;

IN: pathname-docs
ARTICLE: "io.pathnames.special" "Special pathnames"
"If a pathname begins with " { $snippet "resource:" } ", it is resolved relative to the directory containing the current image (see " { $link image } ")."
$nl
"If a pathname begins with " { $snippet "vocab:" } ", then it will be searched for in all current vocabulary roots (see " { $link "add-vocab-roots" } ")."
$nl
"If a pathname begins with " { $snippet "~" } ", it will be searched for in the home directory. Subsequent tildes in the pathname will be construed as literal tilde path or filenames and will not be treated specially. To access a filename named " { $snippet "~" } ", you must construct a path to reference the filename, even if it's within the current directory such as " { $snippet "./~" } "."
$nl
"If a pathname begins with " { $snippet "~" } " and followed by a user name e.g."
{ $snippet "~root" } ", it will be searched for in that users home folder."
;


IN: folder-docs
ARTICLE: "folders" "Folder tools"
"
Provides tools to examine and manipulate folders and files. 
"
    ;

HELP: remove-extension
{ $values { "path" string } { "path" string } }
{ $description "Removes the last extenstion of a path." }
{ $examples
  { $code 
    "\"/path/file.ext\" remove-extension print"
    "/path/file"
  }
}
;

HELP: remove-acl
{ $values { "path" string } }
{ $description "Removes all ACL from a path." }
;

IN: io.directories
HELP: directory-entry
{ $description "A tuple containing the name of a directory entry and its type as one of 
" }
{ $subsections
    +regular-file+
    +directory+
}
;

! HELP: to-folder
! { $values { "path" string } { "directory-entry" directory-entry } { "folder" folder-entry } }
! { $description "Converts the given directory-entry to the given path into a folder object." }
! { $example "USING: folder ;" "\"~/Desktop\" to-folder" "T{ folder-entry f \"Desktop\" +directory+ \"/Users/davec/Desktop\""} print-element 
! { $notes "No Notes" }
! ;
