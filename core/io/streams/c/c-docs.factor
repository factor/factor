USING: help.markup help.syntax io io.files threads
strings byte-arrays io.streams.plain ;
IN: io.streams.c

ARTICLE: "io.streams.c" "ANSI C streams"
"C streams are found in the " { $vocab-link "io.streams.c" } " vocabulary; they are " { $link "stream-protocol" } " implementations which read and write C " { $snippet "FILE*" } " handles."
{ $subsection <c-reader> }
{ $subsection <c-writer> }
"Underlying primitives used to implement the above:"
{ $subsection fopen }
{ $subsection fwrite }
{ $subsection fflush }
{ $subsection fclose }
{ $subsection fgetc }
{ $subsection fread }
"The three standard file handles:"
{ $subsection stdin-handle }
{ $subsection stdout-handle }
{ $subsection stderr-handle } ;

ABOUT: "io.streams.c"

HELP: <c-reader>
{ $values { "handle" "a C FILE* handle" } { "stream" "a new stream" } }
{ $description "Creates a stream which reads data by calling C standard library functions." }
{ $notes "Usually C streams are only used during bootstrap, and non-blocking OS-specific I/O routines are used during normal operation." } ;

HELP: <c-writer>
{ $values { "handle" "a C FILE* handle" } { "stream" "a new stream" } }
{ $description "Creates a stream which writes data by calling C standard library functions." }
{ $notes "Usually C streams are only used during bootstrap, and non-blocking OS-specific I/O routines are used during normal operation." } ;

HELP: fopen
{ $values { "path" "a pathname string" } { "mode" "an access mode specifier" } { "alien" "a C FILE* handle" } }
{ $description "Opens a file named by " { $snippet "path" } ". The " { $snippet "mode" } " parameter should be something like " { $snippet "\"r\"" } " or " { $snippet "\"rw\"" } "; consult the " { $snippet "fopen(3)" } " manual page for details." }
{ $errors "Throws an error if the file could not be opened." }
{ $notes "User code should call " { $link <file-reader> } " or " { $link <file-writer> } " to get a high level stream." } ;

HELP: fwrite ( string alien -- )
{ $values { "string" "a string" } { "alien" "a C FILE* handle" } }
{ $description "Writes a string of text to a C FILE* handle." }
{ $errors "Throws an error if the output operation failed." } ;

HELP: fflush ( alien -- )
{ $values { "alien" "a C FILE* handle" } }
{ $description "Forces pending output on a C FILE* handle to complete." }
{ $errors "Throws an error if the output operation failed." } ;

HELP: fclose ( alien -- )
{ $values { "alien" "a C FILE* handle" } }
{ $description "Closes a C FILE* handle." } ;

HELP: fgetc ( alien -- ch/f )
{ $values { "alien" "a C FILE* handle" } { "ch/f" "a character or " { $link f } } }
{ $description "Reads a single character from a C FILE* handle, and outputs " { $link f } " on end of file." } 
{ $errors "Throws an error if the input operation failed." } ;

HELP: fread ( n alien -- str/f )
{ $values { "n" "a positive integer" } { "alien" "a C FILE* handle" } { "str/f" "a string or " { $link f } } }
{ $description "Reads a sequence of characters from a C FILE* handle, and outputs " { $link f } " on end of file." }
{ $errors "Throws an error if the input operation failed." } ;

HELP: stdin-handle
{ $values { "alien" "a C FILE* handle" } }
{ $description "Outputs the console standard input file handle." } ;

HELP: stdout-handle
{ $values { "alien" "a C FILE* handle" } }
{ $description "Outputs the console standard output file handle." } ;

HELP: stderr-handle
{ $values { "alien" "a C FILE* handle" } }
{ $description "Outputs the console standard error file handle." } ;
