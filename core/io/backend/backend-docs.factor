USING: help.markup help.syntax io io.backend ;
IN: io.backend

HELP: io-multiplex
{ $values { "nanos" "a non-negative integer" } }
{ $contract "Waits up to " { $snippet "nanos" } " nanoseconds for pending I/O requests to complete." } ;

HELP: init-io
{ $contract "Initializes the I/O system. Called on startup." } ;

HELP: init-stdio
{ $contract "Initializes the global " { $link input-stream } " and " { $link output-stream } ". Called on startup." } ;
