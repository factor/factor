USING: help.markup help.syntax quotations hashtables kernel
classes strings ;
IN: io

ARTICLE: "stream-protocol" "Stream protocol"
"The stream protocol consists of a large number of generic words, many of which are optional."
$nl
"A word required to be implemented for all streams:"
{ $subsection stream-close }
"Three words are required for input streams:"
{ $subsection stream-read1 }
{ $subsection stream-read }
{ $subsection stream-read-until }
{ $subsection stream-readln }
"Seven words are required for output streams:"
{ $subsection stream-flush }
{ $subsection stream-write1 }
{ $subsection stream-write }
{ $subsection stream-format }
{ $subsection stream-nl }
{ $subsection make-span-stream }
{ $subsection make-block-stream }
{ $subsection make-cell-stream }
{ $subsection stream-write-table }
"Optional word for network streams:"
{ $subsection set-timeout } ;

ARTICLE: "stdio" "The default stream"
"Various words take an implicit stream parameter from a variable to reduce stack shuffling."
{ $subsection stdio }
"Unless rebound in a child namespace, this variable will be set to a console stream for interacting with the user."
{ $subsection close }
{ $subsection read1 }
{ $subsection read }
{ $subsection read-until }
{ $subsection readln }
{ $subsection flush }
{ $subsection write1 }
{ $subsection write }
{ $subsection print }
{ $subsection nl }
{ $subsection bl }
"Formatted output:"
{ $subsection format }
{ $subsection write-object }
{ $subsection with-style }
{ $subsection with-nesting }
"Tabular output:"
{ $subsection tabular-output }
{ $subsection with-row }
{ $subsection with-cell }
{ $subsection write-cell }
"A pair of combinators support rebinding the " { $link stdio } " variable:"
{ $subsection with-stream }
{ $subsection with-stream* } ;

ARTICLE: "stream-utils" "Stream utilities"
"There are a few useful stream-related words which are not generic, but merely built up from the stream protocol."
$nl
"First, a simple composition of " { $link stream-write } " and " { $link stream-nl } ":"
{ $subsection stream-print }
"Sluring an entire stream into memory all at once:"
{ $subsection lines }
{ $subsection contents }
"Copying the contents of one stream to another:"
{ $subsection stream-copy } ;

ARTICLE: "streams" "Streams"
"Input and output centers on the concept of a " { $emphasis "stream" } ", which is a source or sink of characters. Streams also support formatted output, which may be used to present styled text in a manner independent of output medium."
{ $subsection "stream-protocol" }
{ $subsection "stdio" }
{ $subsection "stream-utils" }
{ $see-also "io.streams.string" "io.streams.lines" "io.streams.plain" "io.streams.duplex" } ;

ABOUT: "streams"

HELP: stream-close
{ $values { "stream" "a stream" } }
{ $contract "Closes the stream. This releases any external resources associated with the stream, such as file handles and network connections. No further operations can be performed on the stream after this call." }
{ $notes "You must close streams after you are finished working with them. A convenient way to automate this is by using the " { $link with-stream } " word." }
$io-error ;

HELP: set-timeout
{ $values { "n" "an integer" } { "stream" "a stream" } }
{ $contract "Sets a timeout, in milliseconds, for closing the stream if there is no activity. Not all streams support timeouts." } 
$io-error ;

HELP: stream-readln
{ $values { "stream" "an input stream" } { "str" string } }
{ $contract "Reads a line of input from the stream. Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: stream-read1
{ $values { "stream" "an input stream" } { "ch/f" "a character or " { $link f } } }
{ $contract "Reads a character of input from the stream. Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: stream-read
{ $values { "n" "a non-negative integer" } { "stream" "an input stream" } { "str/f" "a string or " { $link f } } }
{ $contract "Reads " { $snippet "n" } " characters of input from the stream. Outputs a truncated string or " { $link f } " on stream exhaustion." }
$io-error ;

HELP: stream-read-until
{ $values { "seps" string } { "stream" "an input stream" } { "str/f" "a string or " { $link f } } { "sep/f" "a character or " { $link f } } }
{ $contract "Reads characters from the stream, until the first occurrence of a separator character, or stream exhaustion. In the former case, the separator character is pushed on the stack, and is not part of the output string. In the latter case, the entire stream contents are output, along with " { $link f } "." }
$io-error ;

HELP: stream-write1
{ $values { "ch" "a character" } { "stream" "an output stream" } }
{ $contract "Writes a character of output to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
$io-error ;

HELP: stream-write
{ $values { "str" string } { "stream" "an output stream" } }
{ $contract "Writes a string of output to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
$io-error ;

HELP: stream-flush
{ $values { "stream" "an output stream" } }
{ $contract "Waits for any pending output to complete." }
{ $notes "With many output streams, written output is buffered and not sent to the underlying resource until either the buffer is full, or this word is called." }
$io-error ;

HELP: stream-nl
{ $values { "stream" "an output stream" } }
{ $contract "Writes a line terminator. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output." }
$io-error ;

HELP: stream-format
{ $values { "str" string } { "style" "a hashtable" } { "stream" "an output stream" } }
{ $contract "Writes formatted text to the stream. If the stream does buffering, output may not be performed immediately; use " { $link stream-flush } " to force output."
$nl
"The " { $snippet "style" } " hashtable holds character style information. See " { $link "character-styles" } "." }
$io-error ;

HELP: make-block-stream
{ $values { "quot" "a quotation" } { "style" "a hashtable" } { "stream" "an output stream" } }
{ $contract "Calls the quotation in a new dynamic scope with the " { $link stdio } " stream rebound to a nested paragraph stream, with formatting information applied."
$nl
"Unlike " { $link make-span-stream } ", this creates a new paragraph block in the output."
$nl
"The " { $snippet "style" } " hashtable holds paragraph style information. See " { $link "paragraph-styles" } "." }
$io-error ;

HELP: stream-write-table
{ $values { "table-cells" "a sequence of sequences of table cells" } { "style" "a hashtable" } { "stream" "an output stream" } }
{ $contract "Prints a table of cells produced by " { $link with-cell } "."
$nl
"The " { $snippet "style" } " hashtable holds table style information. See " { $link "table-styles" } "." }
{ $notes "Instead of calling this word directly, use " { $link tabular-output } "." }
$io-error ;

HELP: make-cell-stream
{ $values { "quot" quotation } { "style" hashtable } { "stream" "an output stream" } { "table-cell" object } }
{ $contract "Creates a table cell by calling the quotation in a new scope with a rebound " { $link stdio } " stream. Callers should not make any assumptions about the type of this word's output value; it should be treated like an opaque handle passed to " { $link stream-write-table } "." }
{ $notes "Instead of calling this word directly, use " { $link tabular-output } "." }
$io-error ;

HELP: make-span-stream
{ $values { "style" "a hashtable" } { "quot" "a quotation" } { "stream" "an output stream" } }
{ $contract "Calls the quotation in a new dynamic scope where calls to " { $link write } ", " { $link format } " and other stream output words automatically inherit style settings from " { $snippet "style" } "."
$nl
"Unlike " { $link make-block-stream } ", the quotation's output is inline, and not nested in a paragraph block." }
$io-error ;

HELP: stream-print
{ $values { "str" string } { "stream" "an output stream" } }
{ $description "Writes a newline-terminated string." }
$io-error ;

HELP: stream-copy
{ $values { "in" "an input stream" } { "out" "an output stream" } }
{ $description "Copies the contents of one stream into another, closing both streams when done." } 
$io-error ;

HELP: stdio
{ $var-description "Holds a stream, used for various implicit stream operations. Rebound using " { $link with-stream } " and " { $link with-stream* } "." } ;

HELP: close
{ $contract "Closes the " { $link stdio } " stream." } 
$io-error ;

HELP: readln
{ $values { "str/f" "a string or " { $link f } } }
{ $contract "Reads a line of input from the " { $link stdio } " stream. Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: read1
{ $values { "ch/f" "a character or " { $link f } } }
{ $contract "Reads a character of input from the " { $link stdio } " stream. Outputs " { $link f } " on stream exhaustion." }
$io-error ;

HELP: read
{ $values { "n" "a non-negative integer" } { "str/f" "a string or " { $link f } } }
{ $contract "Reads " { $snippet "n" } " characters of input from the " { $link stdio } " stream. Outputs a truncated string or " { $link f } " on stream exhaustion." }
$io-error ;

HELP: read-until
{ $values { "seps" string } { "str/f" "a string or " { $link f } } { "sep/f" "a character or " { $link f } } }
{ $contract "Reads characters from the " { $link stdio } " stream. until the first occurrence of a separator character, or stream exhaustion. In the former case, the separator character is pushed on the stack, and is not part of the output string. In the latter case, the entire stream contents are output, along with " { $link f } "." }
$io-error ;

HELP: write1
{ $values { "ch" "a character" } }
{ $contract "Writes a character of output to the " { $link stdio } " stream. If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: write
{ $values { "str" string } }
{ $contract "Writes a string of output to the " { $link stdio } " stream. If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: flush
{ $contract "Waits for any pending output to the " { $link stdio } " stream to complete." }
$io-error ;

HELP: nl
{ $contract "Writes a line terminator to the " { $link stdio } " stream. If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
$io-error ;

HELP: format
{ $values { "str" string } { "style" "a hashtable" } }
{ $contract "Writes formatted text to the " { $link stdio } " stream. If the stream does buffering, output may not be performed immediately; use " { $link flush } " to force output." }
{ $notes "Details are in the documentation for " { $link stream-format } "." }
$io-error ;

HELP: with-nesting
{ $values { "style" "a hashtable" } { "quot" "a quotation" } }
{ $contract "Calls the quotation in a new dynamic scope with the " { $link stdio } " stream rebound to a nested paragraph stream, with formatting information applied." }
{ $notes "Details are in the documentation for " { $link make-block-stream } "." }
$io-error ;

HELP: tabular-output
{ $values { "style" "a hashtable" } { "quot" quotation } }
{ $description "Calls a quotation which emits a series of equal-length table rows using " { $link with-row } ". The results are laid out in a tabular fashion on the " { $link stdio } " stream."
$nl
"The " { $snippet "style" } " hashtable holds table style information. See " { $link "table-styles" } "." }
{ $examples
    { $code
        "{ { 1 2 } { 3 4 } }"
        "H{ { table-gap { 10 10 } } } ["
        "    [ [ [ [ . ] with-cell ] each ] with-row ] each"
        "] tabular-output"
    }
}
$io-error ;

HELP: with-row
{ $values { "quot" quotation } }
{ $description "Calls a quotation which emits a series of table cells using " { $link with-cell } ". This word can only be called inside the quotation given to " { $link tabular-output } "." }
$io-error ;

HELP: with-cell
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new scope with the " { $link stdio } " stream rebound. Output performed by the quotation is displayed in a table cell. This word can only be called inside the quotation given to " { $link with-row } "." }
$io-error ;

HELP: write-cell
{ $values { "str" string } }
{ $description "Outputs a table cell containing a single string. This word can only be called inside the quotation given to " { $link with-row } "." }
$io-error ;

HELP: with-style
{ $values { "style" "a hashtable" } { "quot" "a quotation" } }
{ $description "Calls the quotation in a new dynamic scope where calls to " { $link write } ", " { $link format } " and other stream output words automatically inherit style settings from " { $snippet "style" } "." }
{ $notes "Details are in the documentation for " { $link make-span-stream } "." }
$io-error ;

HELP: print
{ $values { "string" string } }
{ $description "Writes a newline-terminated string to the " { $link stdio } " stream." }
$io-error ;

HELP: with-stream
{ $values { "stream" "an input or output stream" } { "quot" "a quotation" } }
{ $description "Calls the quotation in a new dynamic scope, with the " { $link stdio } " variable rebound to  " { $snippet "stream" } ". The stream is closed if the quotation returns or throws an error." } ;

{ with-stream with-stream* } related-words

HELP: with-stream*
{ $values { "stream" "an input or output stream" } { "quot" "a quotation" } }
{ $description "Calls the quotation in a new dynamic scope, with the " { $link stdio } " variable rebound to  " { $snippet "stream" } "." }
{ $notes "This word does not close the stream. Compare with " { $link with-stream } "." } ;

HELP: bl
{ $description "Outputs a space character (" { $snippet "\" \"" } ")." }
$io-error ;

HELP: write-object
{ $values { "str" string } { "obj" "an object" } }
{ $description "Writes a string to the " { $link stdio } " stream, associating it with the object. If formatted output is supported, the string will become a clickable presentation of the object, otherwise this word behaves like a call to " { $link write } "." }
$io-error ;

HELP: lines
{ $values { "stream" "an input stream" } { "seq" "a sequence of strings" } }
{ $description "Reads lines of text until the stream is exhausted, collecting them in a sequence of strings." } ;

HELP: contents
{ $values { "stream" "an input stream" } { "str" string } }
{ $description "Reads the entire contents of a stream into a string." }
$io-error ;
