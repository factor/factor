USING: help.markup help.syntax io.files io.buffers kernel openssl.libssl
strings sequences ;
IN: io.sockets.secure.openssl

HELP: subject-name
{ $values { "certificate" "an SSL peer certificate" } { "host" string } }
{ $description "The subject name of a certificate." } ;

HELP: subject-names-match?
{ $values { "name" "a host name" } { "pattern" "a subject name" } { "?" boolean } }
{ $description "True if the host name matches the subject name." }
{ $examples
    { $code
        "\"www.google.se\" \"*.google.se\" subject-names-match?"
        "t"
    }
} ;

HELP: alternative-dns-names
{ $values { "certificate" "an SSL peer certificate" } { "dns-names" sequence } }
{ $description "Alternative subject names for the certificate." } ;

HELP: do-ssl-connect
{ $values { "ssl-handle" ssl-handle } }
{ $description "Connects the SSL handle to the remote server. Blocks until the connection is established or an error is thrown." } ;

HELP: do-ssl-read
{ $values
  { "buffer" buffer }
  { "ssl-handle" ssl-handle }
  { "event/f" { $maybe "a symbol indicating the desired operation" } } }
{ $description "Reads from the ssl connection to the buffer." } ;

HELP: do-ssl-write
{ $values
  { "buffer" buffer }
  { "ssl-handle" ssl-handle }
  { "event/f" { $maybe "a symbol indicating the desired operation" } } }
{ $description "Writes from the buffer to the ssl connection." } ;

HELP: check-ssl-error
{ $values
  { "ssl-handle" ssl-handle }
  { "ret" "error code returned by an SSL function" }
  { "event/f" { $maybe "a symbol indicating the desired operation" } }
}
{ $description "Checks if the last SSL function returned successfully or not. If so, returns " { $link f } " or a symbol, " { $link +input+ } " or " { $link +output+ } ", that indicates the socket operation required by libssl." } ;

HELP: maybe-handshake
{ $values
  { "ssl-handle" ssl-handle }
} { $description "Performs SSL handshaking (using " { $link SSL_accept } ") if the handle isn't connected. Then sets its state to connected." } ;
