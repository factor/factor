USING: help help.syntax help.markup io ;
IN: io.server

HELP: log-stream
{ $var-description "Holds an output stream for logging messages." }
{ $see-also log-error log-client with-logging } ;

HELP: log-message
{ $values { "str" "a string" } }
{ $description "Logs a message to the log stream. If " { $link log-stream } " is not set, logs to the " { $link stdio } " stream." }
{ $see-also log-error log-client } ;

HELP: log-error
{ $values { "str" "a string" } }
{ $description "Logs an error message." }
{ $see-also log-message log-client } ;

HELP: log-client
{ $values { "client" "a client socket stream" } }
{ $description "Logs an incoming client connection." }
{ $see-also log-message log-error } ;

HELP: with-logging
{ $values { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Calls the quotation in a new dynamic scope where the " { $link log-stream } " is set to a file stream appending to a log file (if " { $snippet "service" } " is not " { $link f } ") or the " { $link stdio } " stream at the time " { $link with-logging } " is called (if " { $snippet "service" } " is " { $link f } ")." } ;

HELP: with-client
{ $values { "quot" "a quotation" } { "client" "a client socket stream" } }
{ $description "Logs a client connection and spawns a new thread that calls the quotation, with the " { $link stdio } " stream set to the client stream. If the quotation throws an error, the client connection is closed, and the error is printed to the " { $link stdio } " stream at the time the thread was spawned." } ;

HELP: with-server
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Starts a TCP/IP server. The quotation is called in a new thread for each client connection, with the client connection being the " { $link stdio } " stream. Client connections are logged to the " { $link stdio } " stream at the time the server was started." } ;

HELP: with-datagrams
{ $values { "seq" "a sequence of address specifiers" } { "service" "a string or " { $link f } } { "quot" "a quotation" } }
{ $description "Starts a UDP/IP server. The quotation is called for each datagram packet received. Datagram packets are logged to the " { $link stdio } " stream at the time the server was started." } ;
