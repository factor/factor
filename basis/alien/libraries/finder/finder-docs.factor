USING: help.markup help.syntax ;
IN: alien.libraries.finder

HELP: find-library*
{ $values
  { "name" "a shared library name" }
  { "path/f" { $maybe "filesystem path" } }
}
{ $description
  "Returns a filesystem path for a plain shared library name, or f if no library can be found."
} ;

HELP: find-library
{ $values
  { "name" "a shared library name" }
  { "path/library-not-found" "a filesystem path or " { $snippet "name" } }
}
{ $description
  "Used to load libraries whose exact filenames is not known in advance:"
  { $code
    "<< \"sqlite\" \"sqlite3\" find-library cdecl add-library >>"
  }
  "Note the parse time evaluation with " { $link POSTPONE: << } "."
} ;
