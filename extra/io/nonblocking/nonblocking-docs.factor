USING: io io.buffers io.backend help.markup help.syntax kernel
byte-arrays sbufs words continuations byte-vectors classes ;
IN: io.nonblocking

ARTICLE: "io.nonblocking" "Non-blocking I/O implementation"
"On Windows and Unix, Factor implements blocking file and network streams on top of a non-blocking I/O substrate, ensuring that Factor threads will yield when performing I/O. This substrate is implemented in the " { $vocab-link "io.nonblocking" } " vocabulary."
$nl
"A " { $emphasis "port" } " is a stream using non-blocking I/O substrate:"
{ $subsection port }
{ $subsection <port> }
{ $subsection <buffered-port> }
"Input ports:"
{ $subsection input-port }
{ $subsection <input-port> }
"Output ports:"
{ $subsection output-port }
{ $subsection <output-port> }
"Global native I/O protocol:"
{ $subsection io-backend }
{ $subsection init-io }
{ $subsection init-stdio }
{ $subsection io-multiplex }
"Per-port native I/O protocol:"
{ $subsection init-handle }
{ $subsection (wait-to-read) }
"Additionally, the I/O backend must provide an implementation of the " { $link stream-flush } " and " { $link dispose } " generic words."
$nl
"Dummy ports which should be used to implement networking:"
{ $subsection server-port }
{ $subsection datagram-port } ;

ABOUT: "io.nonblocking"

HELP: port
{ $class-description "Instances of this class present a blocking stream interface on top of an underlying non-blocking I/O system, giving the illusion of blocking by yielding the thread which is waiting for input or output."
$nl
"Ports have the following slots:"
{ $list
    { { $snippet "handle" } " - a native handle identifying the underlying native resource used by the port" }
    { { $snippet "error" } " - the most recent I/O error, if any. This error is thrown to the waiting thread when " { $link pending-error } " is called by stream operations" }
    { { $snippet "type" } " - a symbol identifying the port's intended purpose" }
    { { $snippet "eof" } " - a flag indicating if the port has reached the end of file while reading" }
} } ;

HELP: input-port
{ $class-description "The class of ports implementing the input stream protocol." } ;

HELP: output-port
{ $class-description "The class of ports implementing the output stream protocol." } ;

HELP: init-handle
{ $values { "handle" "a native handle identifying an I/O resource" } }
{ $contract "Prepares a native handle for use by the port; called by " { $link <port> } "." } ;

HELP: <port>
{ $values { "handle" "a native handle identifying an I/O resource" } { "class" class } { "port" "a new " { $link port } } }
{ $description "Creates a new " { $link port } " with no buffer." }
$low-level-note ;

HELP: <buffered-port>
{ $values { "handle" "a native handle identifying an I/O resource" } { "class" class } { "port" "a new " { $link port } } }
{ $description "Creates a new " { $link port } " using the specified native handle and a default-sized I/O buffer." } 
$low-level-note ;

HELP: <input-port>
{ $values { "handle" "a native handle identifying an I/O resource" } { "input-port" "a new " { $link input-port } } }
{ $description "Creates a new " { $link input-port } " using the specified native handle and a default-sized input buffer." } 
$low-level-note ;

HELP: <output-port>
{ $values { "handle" "a native handle identifying an I/O resource" } { "output-port" "a new " { $link output-port } } }
{ $description "Creates a new " { $link output-port } " using the specified native handle and a default-sized input buffer." } 
$low-level-note ;

HELP: pending-error
{ $values { "port" port } }
{ $description "If an error occurred while the I/O thread was performing input or output on this port, this error will be thrown to the caller." } ;

HELP: (wait-to-read)
{ $values { "port" input-port } }
{ $contract "Suspends the current thread until the port's buffer has data available for reading." } ;

HELP: wait-to-read
{ $values { "count" "a non-negative integer" } { "port" input-port } }
{ $description "If the port's buffer has at least " { $snippet "count" } " unread bytes, returns immediately, otherwise suspends the current thread until some data is available for reading." } ;

HELP: wait-to-read1
{ $values { "port" input-port } }
{ $description "If the port's buffer has unread data, returns immediately, otherwise suspends the current thread until some data is available for reading." } ;

HELP: unless-eof
{ $values { "port" input-port } { "quot" "a quotation with stack effect " { $snippet "( port -- value )" } } { "value" object } }
{ $description "If the port has reached end of file, outputs " { $link f } ", otherwise applies the quotation to the port." } ;

HELP: can-write?
{ $values { "len" "a positive integer" } { "buffer" buffer } { "?" "a boolean" } }
{ $description "Tests if the port's output buffer can accomodate " { $snippet "len" } " bytes. If the buffer is empty, this always outputs " { $link t } ", since in that case the buffer will be grown automatically." } ;
