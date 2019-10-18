USING: help.markup help.syntax io ;
IN: io.streams.plain

ARTICLE: "io.streams.plain" "Plain writer streams"
"Plain writer streams wrap an underlying stream and provide a default implementation of "
{ $link stream-nl } ", "
{ $link stream-format } ", "
{ $link make-span-stream } ", "
{ $link make-block-stream } " and "
{ $link make-cell-stream } "."
{ $subsection plain-writer }
{ $subsection <plain-writer> } ;

ABOUT: "io.streams.plain"

HELP: plain-writer
{ $class-description "An output stream which delegates to an underlying stream while providing an implementation of the extended stream output protocol in a trivial way. Plain writers are created by calling " { $link <plain-writer> } "." }
{ $see-also "stream-protocol" } ;

HELP: <plain-writer>
{ $values { "stream" "an input stream" } { "new-stream" "an input stream" } }
{ $description "Creates a new " { $link plain-writer } "." }
{ $notes "Stream constructors should call this word to wrap streams that do not natively support the extended stream output protocol." }
{ $see-also "stream-protocol" } ;
