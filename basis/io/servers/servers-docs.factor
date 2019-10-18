USING: calendar classes concurrency.semaphores help.markup help.syntax
io io.servers.private io.sockets io.sockets.secure quotations
sequences ;
IN: io.servers

ARTICLE: "server-config" "Threaded server configuration"
"The " { $link threaded-server } " tuple has a variety of slots which can be set before starting the server with " { $link start-server } "."
{ $subsections
    "server-config-logging"
    "server-config-listen"
    "server-config-limit"
    "server-config-stream"
    "server-config-handler"
} ;

ARTICLE: "server-config-logging" "Logging connections"
"The " { $snippet "name" } " slot of a threaded server instance should be set to a string naming the logging service name to use. See " { $link "logging" } " for details." ;

ARTICLE: "server-config-listen" "Setting ports to listen on"
"The " { $snippet "insecure" } " slot of a threaded server instance contains an integer, an address specifier, or a sequence of address specifiers. Integer port numbers are interpreted as an " { $link inet4 } "/" { $link inet6 } " pair listening on all interfaces for given port number. All other address specifiers are interpreted as per " { $link "network-addressing" } "."
$nl
"The " { $snippet "secure" } " slot of a threaded server instance is interpreted in the same manner as the " { $snippet "insecure" } " slot, except that secure encrypted connections are then allowed. If this slot is set, the " { $snippet "secure-config" } " slot should also be set to a " { $link secure-config } " instance containing SSL server configuration. See " { $link "ssl-config" } " for details."
$nl
"Two utility words for producing address specifiers:"
{ $subsections
    local-server
    internet-server
} ;

ARTICLE: "server-config-limit" "Limiting connections"
"The " { $snippet "max-connections" } " slot is initially set to " { $link f } ", which disables connection limiting, but can be set to an integer specifying the maximum number of simultaneous connections."
$nl
"Another method to limit connections is to set the " { $snippet "semaphore" } " slot to a " { $link semaphore } ". The server will hold the semaphore while servicing the client connection."
$nl
"Setting the " { $snippet "max-connections" } " slot is equivalent to storing a semaphore with this initial count in the " { $snippet "semaphore" } " slot. The " { $snippet "semaphore" } " slot is useful for enforcing a maximum connection count shared between multiple threaded servers. See " { $link "concurrency.semaphores" } " for details." ;

ARTICLE: "server-config-stream" "Client stream parameters"
"The " { $snippet "encoding" } " and " { $snippet "timeout" } " slots of the threaded server can be set to an encoding descriptor or a " { $link duration } ", respectively. See " { $link "io.encodings" } " and " { $link "io.timeouts" } " for details." ;

ARTICLE: "server-config-handler" "Client handler quotation"
"The " { $snippet "handler" } " slot of a threaded server instance should be set to a quotation which handles client connections. Client handlers are run in their own thread, with the following variables rebound:"
{ $list
    { $link input-stream }
    { $link output-stream }
    { $link local-address }
    { $link remote-address }
    { $link threaded-server }
}
"An alternate way to implement client handlers is to subclass " { $link threaded-server } ", and define a method on " { $link handle-client* } "."
$nl
"The two methods are equivalent, representing a functional versus an object-oriented approach to the problem." ;

ARTICLE: "server-examples" "Threaded server examples"
"The " { $vocab-link "time-server" } " vocabulary implements a simple threaded server which sends the current time to the client. The " { $vocab-link "concurrency.distributed" } ", " { $vocab-link "ftp.server" } ", and " { $vocab-link "http.server" } " vocabularies demonstrate more complex usage of the threaded server library." ;

ARTICLE: "io.servers" "Threaded servers"
"The " { $vocab-link "io.servers" } " vocabulary implements a generic server abstraction for " { $link "network-connection" } ". A set of threads listen for connections, and additional threads are spawned for each client connection. In addition to this basic functionality, it provides some advanced features such as logging, connection limits and secure socket support."
{ $subsections "server-examples" }
"Creating threaded servers with client handler quotations:"
{ $subsections <threaded-server> }
"Client handlers can also be implemented by subclassing a threaded server; see " { $link "server-config-handler" } " for details:"
{ $subsections
    threaded-server
    new-threaded-server
    handle-client*
}
"The server must be configured before it can be started."
{ $subsections "server-config" }
"Starting the server:"
{ $subsections start-server }
"Stopping the server:"
{ $subsections stop-server }
"Waiting for the server to stop:"
{ $subsections wait-for-server }
"Combinator for running a server:"
{ $subsections with-threaded-server }
"From within the dynamic scope of a client handler, several words can be used to interact with the threaded server:"
{ $subsections
    stop-this-server
    secure-addr
    insecure-addr
}
"Additionally, the " { $link local-address } " and "
{ $link remote-address } " variables are set, as in " { $link with-client } "." ;

ABOUT: "io.servers"

HELP: configurable-addrspecs
{ $values { "addrspecs" sequence } { "addrspecs'" sequence } }
{ $description "Filter the list of addrspecs so that only those that are supported by the host system remains." } ;

HELP: threaded-server
{ $var-description "In client handlers, stores the current threaded server instance." }
{ $class-description "The class of threaded servers. New instances are created with " { $link <threaded-server> } ". This class may be subclassed, and instances of subclasses should be created with " { $link new-threaded-server } ". See " { $link "server-config" } " for slot documentation." } ;

HELP: new-threaded-server
{ $values { "encoding" "an encoding descriptor" } { "class" class } { "threaded-server" threaded-server } }
{ $description "Creates a new instance of a subclass of " { $link threaded-server } ". Subclasses can implement the " { $link handle-client* } " generic word." } ;

HELP: <threaded-server>
{ $values { "encoding" "an encoding descriptor" } { "threaded-server" threaded-server } }
{ $description "Creates a new threaded server with streams encoded " { $snippet "encoding" } ". Its slots should be filled in as per " { $link "server-config" } ", before " { $link start-server } " is called to begin waiting for connections." } ;

HELP: remote-address
{ $var-description "Variable holding the address specifier of the current client connection. See " { $link "network-addressing" } "." } ;

HELP: handle-client*
{ $values { "threaded-server" threaded-server } }
{ $contract "Handles a client connection. Default implementation calls quotation stored in the " { $snippet "handler" } " slot of the threaded server." } ;

HELP: start-server
{ $values { "threaded-server" threaded-server } }
{ $description "Starts a threaded server and returns after the server is fully running. Throws an error if any of the ports cannot be acquired." }
{ $notes "Use " { $link stop-server } " or " { $link stop-this-server } " to stop the server." } ;

HELP: stop-server
{ $values { "threaded-server" threaded-server } }
{ $description "Stops a threaded server, preventing it from accepting any more connections. All client connections which have already been opened continue to be serviced." } ;

HELP: wait-for-server
{ $values { "threaded-server" threaded-server } }
{ $description "Waits for a threaded server to stop serving new connections." } ;

HELP: stop-this-server
{ $description "Stops the current threaded server, preventing it from accepting any more connections. All client connections which have already been opened continue to be serviced." } ;

HELP: with-threaded-server
{ $values
    { "threaded-server" threaded-server } { "quot" quotation }
}
{ $description "Runs a server and calls a quotation, stopping the server once the quotation returns." } ;

HELP: secure-addr
{ $values { "addrspec" "an addrspec" } }
{ $description "Outputs one of the port numbers on which the current threaded server accepts secure socket connections. Outputs " { $link f } " if the current threaded server does not accept secure socket connections." }
{ $notes "Can only be used from the dynamic scope of a " { $link handle-client* } " call." } ;

HELP: insecure-addr
{ $values { "addrspec" "an addrspec" } }
{ $description "Outputs one of the port numbers on which the current threaded server accepts ordinary socket connections. Outputs " { $link f } " if the current threaded server does not accept ordinary socket connections." }
{ $notes "Can only be used from the dynamic scope of a " { $link handle-client* } " call." } ;
