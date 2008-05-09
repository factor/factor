USING: help help.syntax help.markup io ;
IN: io.server

HELP: with-server
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "encoding" "an encoding to use for client connections" } { "quot" "a quotation" } }
{ $description "Starts a TCP/IP server. The quotation is called in a new thread for each client connection, with the client connection being both the " { $link input-stream } " and " { $link output-stream } "." } ;

HELP: with-datagrams
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Starts a UDP/IP server. The quotation is called for each datagram packet received." } ;
