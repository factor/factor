USING: help.markup help.syntax io.sockets.secure namespaces quotations ;
IN: io.sockets.secure.schannel

HELP: schannel
{ $description "The optional native Windows TLS backend. Set "
  { $link secure-socket-backend } " to this singleton before creating secure contexts or sockets to select Schannel. OpenSSL remains the default. Requires Windows 10 version 1809 or later."
  $nl
  "The " { $snippet "TLS" } " method enables TLS 1.2 and newer, subject to Windows policy; "
  { $snippet "TLSv1.2" } " restricts negotiation to TLS 1.2. TLS 1.3 requires a Windows version that supports it."
  $nl
  "Certificate verification defaults to enabled and uses Windows trust and peer-name validation. Custom "
  { $snippet "ca-file" } " and " { $snippet "ca-path" } " settings are rejected."
  $nl
  "The " { $snippet "key-file" } " and " { $snippet "password" }
  " settings load a PKCS#12 (.pfx/.p12) certificate and private key for servers or client authentication. PEM files are not supported. The certificate store stays in memory; imported Windows private-key containers are deleted when the context and its last socket are disposed. Use "
  { $link with-secure-context } " to scope their lifetime."
  $nl
  "ALPN protocols use the existing " { $snippet "alpn-supported-protocols" }
  " configuration slot. Socket I/O and timeouts use the cooperative Windows I/O backend." } ;

HELP: with-schannel
{ $values { "quot" quotation } }
{ $description "Runs a quotation with Schannel selected as the secure socket backend. Create any explicit secure context inside the quotation. Restores the previous backend when the quotation returns or throws." }
{ $code
  "USING: http.client io.sockets.secure.schannel ;"
  "[ \"https://example.com/\" http-get ] with-schannel"
}
{ $notes "For persistent selection, use "
  { $snippet "schannel secure-socket-backend set-global" } ". Existing sockets retain their backend." } ;

HELP: schannel-alpn-protocol
{ $values { "socket" schannel-handle } { "protocol/f" "a string or f" } }
{ $description "Returns the ALPN protocol selected during the completed handshake, or f if no protocol was negotiated." } ;

ARTICLE: "io.sockets.secure.schannel" "Native Windows TLS"
"Schannel is an optional backend for Factor's secure socket API."
{ $subsections schannel with-schannel schannel-alpn-protocol } ;

ABOUT: "io.sockets.secure.schannel"
