USING: help.markup help.syntax io io.backend strings
byte-arrays ;

HELP: io-multiplex
{ $values { "ms" "a non-negative integer" } }
{ $contract "Waits up to " { $snippet "ms" } " milliseconds for pending I/O requests to complete." } ;

HELP: init-io
{ $contract "Initializes the I/O system. Called on startup." } ;

HELP: init-stdio
{ $contract "Initializes the global " { $link stdio } " stream.  Called on startup." } ;
