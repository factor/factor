USING: io io.buffers io.backend help.markup help.syntax kernel
byte-arrays sbufs words continuations destructors
byte-vectors classes ;
IN: io.ports

ARTICLE: "io.ports" "Non-blocking I/O implementation"
"On Windows and Unix, Factor implements blocking file and network streams on top of a non-blocking I/O substrate, ensuring that Factor threads will yield when performing I/O. This substrate is implemented in the " { $vocab-link "io.ports" } " vocabulary."
$nl
"A " { $emphasis "port" } " is a stream using non-blocking I/O substrate:"
{ $subsections
    port
    <port>
    <buffered-port>
}
"Input ports:"
{ $subsections
    input-port
    <input-port>
}
"Output ports:"
{ $subsections
    output-port
    <output-port>
}
"Global native I/O protocol:"
{ $subsections
    io-backend
    init-io
    init-stdio
    io-multiplex
}
"Per-port native I/O protocol:"
{ $subsections
    (wait-to-read)
    (wait-to-write)
}
"Additionally, the I/O backend must provide an implementation of the " { $link dispose } " generic word." ;

ABOUT: "io.ports"

HELP: port
{ $class-description "Instances of this class present a blocking stream interface on top of an underlying non-blocking I/O system, giving the illusion of blocking by yielding the thread which is waiting for input or output." } ;

HELP: shutdown
{ $values { "handle" "a port handle" } }
{ $description "Called when a port is being disposed." } ;

HELP: input-port
{ $class-description "The class of ports implementing the input stream protocol." } ;

HELP: output-port
{ $class-description "The class of ports implementing the output stream protocol." } ;

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

HELP: (wait-to-read)
{ $values { "port" input-port } }
{ $contract "Suspends the current thread until the port's buffer has data available for reading." } ;

HELP: wait-to-read
{ $values { "port" input-port } { "eof?" boolean } }
{ $description "If the port's buffer has unread data, returns immediately, otherwise suspends the current thread until some data is available for reading. If the buffer was empty and no more data could be read, outputs " { $link t } " to indicate end-of-file; otherwise outputs " { $link f } "." } ;
