IN: io.pools
USING: help.markup help.syntax destructors quotations ;

HELP: pool
{ $class-description "A connection pool. Instances of this class are not intended to be instantiated directly, only subclasses should be instantiated, for example " { $link datagram-pool } "." } ;

HELP: <pool>
{ $values { "class" "a subclass of " { $link pool } } { "pool" pool } }
{ $description "Creates a new connection pool." }
{ $notes "To avoid resource leaks, pools must be disposed of by calling " { $link dispose } " when no longer in use." } ;

HELP: with-pool
{ $values { "pool" pool } { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope with the " { $link pool } " variable set to " { $snippet "pool" } ". The pool is disposed of after the quotation returns, or if an error is thrown." } ;

HELP: acquire-connection
{ $values { "pool" pool } { "conn" "a connection" } }
{ $description "Outputs a connection from the pool, preferring to take an existing one, creating a new one with " { $link make-connection } " if the pool is empty." } ;

HELP: return-connection
{ $values { "conn" "a connection" } { "pool" pool } }
{ $description "Returns a connection to the pool." } ;

HELP: with-pooled-connection
{ $values { "pool" pool } { "quot" { $quotation ( conn -- ) } } }
{ $description "Calls a quotation with a pooled connection on the stack. If the quotation returns successfully, the connection is returned to the pool; if the quotation throws an error, the connection is disposed of with " { $link dispose } "." } ;

HELP: make-connection
{ $values { "pool" pool } { "conn" "a connection" } }
{ $contract "Makes a connection for the pool." } ;

HELP: datagram-pool
{ $class-description "A pool of datagram sockets bound to the address stored in the " { $snippet "addrspec" } " slot." } ;

HELP: <datagram-pool>
{ $values { "addrspec" "an address specifier" } { "pool" datagram-pool } }
{ $description "Creates a new " { $link datagram-pool } ". The port number of the " { $snippet "addrspec" } " should be 0, otherwise creation of more than one datagram socket will raise an error." }
{ $examples
    { $code "f 0 <inet4> <datagram-pool>" }
} ;

ARTICLE: "io.pools" "Connection pools"
"Connection pools are implemented in the " { $snippet "io.pools" } " vocabulary. They are used to reuse sockets and connections which may be potentially expensive to create and destroy."
$nl
"The class of connection pools:"
{ $subsections pool }
"Creating connection pools:"
{ $subsections <pool> }
"A utility combinator:"
{ $subsections with-pool }
"Acquiring and returning connections, and a utility combinator:"
{ $subsections
    acquire-connection
    return-connection
    with-pooled-connection
}
"Pools are not created directly, instead one uses subclasses which implement a generic word:"
{ $subsections make-connection }
"One example is a datagram socket pool:"
{ $subsections
    datagram-pool
    <datagram-pool>
} ;

ABOUT: "io.pools"
