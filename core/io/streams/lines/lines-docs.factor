USING: help.markup help.syntax io strings ;
IN: io.streams.lines

ARTICLE: "io.streams.lines" "Line reader streams"
"Line reader streams wrap an underlying stream and provide a default implementation of " { $link stream-readln } "."
{ $subsection line-reader }
{ $subsection <line-reader> } ;

ABOUT: "io.streams.lines"

HELP: line-reader
{ $class-description "An input stream which delegates to an underlying stream while providing an implementation of the " { $link stream-readln } " word in terms of the underlying stream's " { $link stream-read-until } ". Line readers are created by calling " { $link <line-reader> } "." } ;

HELP: <line-reader>
{ $values { "stream" "an input stream" } { "new-stream" "an input stream" } }
{ $description "Creates a new " { $link line-reader } "." }
{ $notes "Stream constructors should call this word to wrap streams that do not natively support reading lines. Unix (" { $snippet "\\n" } "), Windows (" { $snippet "\\r\\n" } ") and MacOS (" { $snippet "\\r" } ") line endings are supported." } ;
