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
  $nl
  "On Linux, libraries are searched in " { $snippet "LD_LIBRARY_PATH" }
  " before the system directories and linker cache. Nix and Guix development environments can expose their runtime libraries this way."
  $nl
  "A wrapper may set " { $snippet "FACTOR_LD_SO_CACHE" }
  " to a UTF-8 file containing an " { $snippet "ldconfig -p" }
  " listing. This replaces the system cache lookup. Each candidate is checked for a native shared-library ELF header; the listing's architecture labels are not used to select the CPU."
} ;
