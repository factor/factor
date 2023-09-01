USING: help.markup help.syntax io kernel quotations sequences ;
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
    change-file-contents
    file-lines
    set-file-lines
    change-file-lines
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
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Opens a file for reading and calls the quotation using " { $link with-input-stream } "." }
{ $errors "Throws an error if the file is unreadable." } ;

HELP: with-file-writer
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Opens a file for writing using the given encoding and calls the quotation using " { $link with-output-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: with-file-appender
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Opens a file for appending using the given encoding and calls the quotation using " { $link with-output-stream } "." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: set-file-lines
{ $values { "seq" "an array of strings" } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to the strings with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-lines
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "seq" "an array of strings" } }
{ $description "Opens the file at the given path using the given encoding, and returns a list of the lines in that file." }
{ $examples
  { $example
    "USING: io.files io.encodings.utf8 prettyprint sequences ;"
    "\"resource:core/kernel/kernel.factor\" utf8 file-lines first ."
    "\"! Copyright (C) 2004, 2009 Slava Pestov.\""
  }
}
{ $errors "Throws an error if the file cannot be opened for reading." } ;

HELP: change-file-lines
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Reads the file lines, transforms the file lines, and writes them back to the same file name." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: set-file-contents
{ $values { "seq" sequence } { "path" "a pathname string" } { "encoding" "an encoding descriptor" } }
{ $description "Sets the contents of a file to a sequence with the given encoding." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: change-file-contents
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "quot" quotation } }
{ $description "Reads the file, transforms the file contents, and writes it back to the same file name." }
{ $errors "Throws an error if the file cannot be opened for writing." } ;

HELP: file-contents
{ $values { "path" "a pathname string" } { "encoding" "an encoding descriptor" } { "seq" sequence } }
{ $description "Opens the file at the given path using the given encoding, and the contents of that file as a sequence." }
{ $errors "Throws an error if the file cannot be opened for reading." } ;

{ set-file-lines file-lines change-file-lines set-file-contents file-contents change-file-contents } related-words

HELP: file-exists?
{ $values { "path" "a pathname string" } { "?" boolean } }
{ $description "Tests if the file named by " { $snippet "path" } " exists." } ;

HELP: if-file-exists
{ $values { "path" "a pathname string" } { "true" { $quotation ( ..a path -- ..b ) } } { "false" { $quotation ( ..a path -- ..b ) } } }
{ $description "If " { $snippet "path" } " is a file that exists, calls the " { $snippet "true" } " quotation, otherwise calls the " { $snippet "false" } " quotation." }
{ $notes "It is possible for the file to be created or deleted after the call to " { $link file-exists? } " but before running " { $snippet "true" } " or " { $snippet "false" } ". If that is a concern, you might want to open the file for reading or writing, as needed." } ;

HELP: when-file-exists
{ $values { "path" "a pathname string" } { "quot" { $quotation ( ... path -- ... ) } } }
{ $description "If " { $snippet "path" } " is a file that exists, calls the " { $snippet "quot" } " quotation." }
{ $notes "It is possible for the file to be created or deleted after the call to " { $link file-exists? } " but before running " { $snippet "quot" } ". If that is a concern, you might want to open the file for reading or writing, as needed." } ;

HELP: unless-file-exists
{ $values { "path" "a pathname string" } { "quot" { $quotation ( ... path -- ... ) } } }
{ $description "If " { $snippet "path" } " is a file that does not exist, calls the " { $snippet "quot" } " quotation." }
{ $notes "It is possible for the file to be created or deleted after the call to " { $link file-exists? } " but before running " { $snippet "quot" } ". If that is a concern, you might want to open the file for reading or writing, as needed." } ;

{ if-file-exists when-file-exists unless-file-exists } related-words
