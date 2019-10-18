USING: help.markup help.syntax io io.backend strings
byte-arrays ;

HELP: io-multiplex
{ $values { "us" "a non-negative integer" } }
{ $contract "Waits up to " { $snippet "us" } " microseconds for pending I/O requests to complete." } ;

HELP: init-io
{ $contract "Initializes the I/O system. Called on startup." } ;

HELP: init-stdio
{ $contract "Initializes the global " { $link input-stream } " and " { $link output-stream } ".  Called on startup." } ;
