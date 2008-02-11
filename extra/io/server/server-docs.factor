USING: help help.syntax help.markup io ;
IN: io.server

HELP: with-client
{ $values { "quot" "a quotation" } { "client" "a client socket stream" } }
{ $description "Logs a client connection and spawns a new thread that calls the quotation, with the " { $link stdio } " stream set to the client stream. If the quotation throws an error, the client connection is closed, and the error is printed to the " { $link stdio } " stream at the time the thread was spawned." } ;

HELP: with-server
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Starts a TCP/IP server. The quotation is called in a new thread for each client connection, with the client connection being the " { $link stdio } " stream. Client connections are logged to the " { $link stdio } " stream at the time the server was started." } ;

HELP: with-datagrams
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Starts a UDP/IP server. The quotation is called for each datagram packet received. Datagram packets are logged to the " { $link stdio } " stream at the time the server was started." } ;
