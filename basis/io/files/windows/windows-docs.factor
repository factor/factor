USING: help.markup help.syntax ;
IN: io.files.windows

HELP: open-read
{ $values { "path" "a filesystem path" } { "win32-file" "a win32 file-handle" } }
{ $description "Opens a file for reading and returns a filehandle to it." }
{ $examples
  { $unchecked-example
    "USING: io.files.windows prettyprint ;"
    "\"resource:core/kernel/kernel.factor\" absolute-path open-read ."
    "T{ win32-file { handle ALIEN: 234 } { ptr 0 } }"
  }
} ;
