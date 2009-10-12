USING: help.markup help.syntax io strings arrays io.backend
io.files.private quotations sequences ;
IN: io.files

ARTICLE: "io.files.examples" "Examples of reading and writing files"
"Sort the lines in a file and write them back to the same file:"
{ $code
    "USING: io io.encodings.utf8 io.files sequences sorting ;"
    "\"lines.txt\" utf8 [ file-lines natural-sort ] 2keep set-file-lines"
}
"Read 1024 bytes from a file:"
{ $code
    "USING: io io.encodings.binary io.files ;"
    "\"data.bin\" binary [ 1024 read ] with-file-reader"
} ;

ARTICLE: "io.files" "Reading and writing files"
{ $subsections "io.files.examples" }
"File streams:"
{ $subsections
    <file-reader>
    <file-writer>
    <file-appender>
}
"Reading and writing the entire contents of a file; this is only recommended for smaller files:"
{ $subsections
    file-contents
    set-file-contents
    file-lines
    set-file-lines
}
"Utility combinators:"
{ $subsections
    with-file-reader
    with-file-writer
    with-file-appender
} ;

ABOUT: "io.files"

HELP: <file-reader>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "stream" "an input stream" } }
{ $description "Outputs an input stream for reading from the specified pathname using the given encoding." }
{ $notes "Most code should use " { $link with-file-reader } " instead, to ensure the stream is properly disposed of after." }
{ $errors "Throws an error if the file is unreadable." } ;

HELP: <file-writer>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "stream" "an output stream" } }
{ $description "Outputs an output stream for writing to the specified pathname using the given encoding. The file's length is truncated to zero." }
{ $notes "Most code should use " { $link with-file-writer } " instead, to ensure the stream is properly disposed of after." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: <file-appender>
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "stream" "an output stream" } }
{ $description "Outputs an output stream for writing to the specified pathname using the given encoding. The stream begins writing at the end of the file." }
{ $notes "Most code should use " { $link with-file-appender } " instead, to ensure the stream is properly disposed of after." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: with-file-reader
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for reading and calls the quotation using " { $link with-input-stream } "." }
{ $errors "Throws an error if the file is unreadable." } ;

HELP: with-file-writer
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for writing using the given encoding and calls the quotation using " { $link with-output-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: with-file-appender
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" "a quotation" } }
{ $description "Opens a file for appending using the given encoding and calls the quotation using " { $link with-output-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: set-file-lines
{ $values { "seq" "an array of strings" } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to the strings with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-lines
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "seq" "an array of strings" } }
{ $description "Opens the file at the given path using the given encoding, and returns a list of the lines in that file." }
{ $errors "Throws an error if the file cannot be opened for reading." } ;

HELP: set-file-contents
{ $values { "seq" sequence } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to a sequence with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-contents
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "seq" sequence } }
{ $description "Opens the file at the given path using the given encoding, and the contents of that file as a sequence." }
{ $errors "Throws an error if the file cannot be opened for reading." } ;

{ set-file-lines file-lines set-file-contents file-contents } related-words

HELP: exists?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if the file named by " { $snippet "path" } " exists." } ;
