IN: io.logging
USING: help.markup help.syntax io ;

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

