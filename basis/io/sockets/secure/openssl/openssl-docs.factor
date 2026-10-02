USING: help.markup help.syntax io.files io.buffers io.sockets.secure
kernel openssl.libssl quotations strings sequences ;
IN: io.sockets.secure.openssl

HELP: with-openssl
{ $values { "quot" quotation } }
{ $description "Runs a quotation with OpenSSL selected as the secure socket backend. Create any explicit secure context inside the quotation. Restores the previous backend when the quotation returns or throws." }
{ $code
  "USING: http.client io.sockets.secure.openssl ;"
  "[ \"https://example.com/\" http-get ] with-openssl"
}
{ $notes "For persistent selection, use "
  { $snippet "openssl secure-socket-backend set-global" }
  ". Existing sockets retain their backend. OpenSSL requires its native libraries to be installed." } ;

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

HELP: certificate-matches?
{ $values { "host" string } { "certificate" "an SSL peer certificate" } { "?" boolean } }
{ $description "Checks the certificate identity against a DNS name or IP address. DNS subject alternative names take precedence over the common name, and a wildcard matches one nonempty label. IP addresses must match an IP subject alternative name. Host names containing a null character are rejected. Uses equivalent local checks when the SSL library lacks native identity checking functions." } ;

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
