USING: help.markup help.syntax io ;
IN: io.streams.plain

ARTICLE: "io.streams.plain" "Plain writer streams"
"Plain writer streams wrap an underlying stream and provide a default implementation of "
{ $link stream-nl } ", "
{ $link stream-format } ", "
{ $link make-span-stream } ", "
{ $link make-block-stream } " and "
{ $link make-cell-stream } "."
{ $subsection plain-writer } ;

ABOUT: "io.streams.plain"

HELP: plain-writer
{ $class-description "An output stream mixin providing an implementation of the extended stream output protocol in a trivial way." }
{ $see-also "stream-protocol" } ;
