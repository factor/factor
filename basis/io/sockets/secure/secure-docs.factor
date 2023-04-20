USING: io help.markup help.syntax calendar quotations strings io.sockets ;
IN: io.sockets.secure

HELP: secure-socket-timeout
{ $var-description "Timeout for operations not associated with a constructed port instance, such as SSL handshake and shutdown. Represented as a " { $link duration } "." } ;

HELP: TLS
{ $description "Possible value for the " { $snippet "method" } " slot of a " { $link secure-config } "."
$nl
"TLS uses the newest protocol (TLSv1.3 as of 4/20/2023) for secure socket communications." } ;

HELP: TLSv1
{ $description "Possible value for the " { $snippet "method" } " slot of a " { $link secure-config } "."
$nl
"TLSv1 is an older protocol for secure socket communications." } ;

HELP: TLSv1.1
{ $description "Possible value for the " { $snippet "method" } " slot of a " { $link secure-config } "."
$nl
"TLSv1.1 is an older protocol for secure socket communications." } ;

HELP: TLSv1.2
{ $description "Possible value for the " { $snippet "method" } " slot of a " { $link secure-config } "."
$nl
"TLSv1.2 is an older protocol for secure socket communications." } ;

ARTICLE: "ssl-methods" "SSL/TLS methods"
"The " { $snippet "method" } " slot of a " { $link secure-config } " can be set to one of the following values:"
{ $subsections
    TLS
    TLSv1
    TLSv1.1
    TLSv1.2
}
"The default value is " { $link TLS } "." ;

HELP: secure-config
{ $class-description "Instances represent secure socket configurations." } ;

HELP: <secure-config>
{ $values { "config" secure-config } }
{ $description "Creates a new secure socket configuration with default values." } ;

ARTICLE: "ssl-key-file" "The key file and password"
"The " { $snippet "key-file" } " and " { $snippet "password" } " slots of a " { $link secure-config } " can be set to a private key file in PEM format. These slots are required for secure servers, and also for clients when client-side authentication is used." ;

ARTICLE: "ssl-ca-file" "The CA file and path"
"The " { $snippet "ca-file" } " slot of a " { $link secure-config } " can contain the path of a file with a list of trusted certificates in PEM format. The " { $snippet "ca-path" } " slot can contain the path of a directory of trusted certifications."
$nl
"One of these slots are required to be specified so that secure client sockets can verify server certificates."
$nl
"See " { $url "http://www.openssl.org/docs/ssl/SSL_CTX_load_verify_locations.html" } " for details." ;

ARTICLE: "ssl-dh-file" "Diffie-Hellman parameter file"
"The " { $snippet "dh-file" } " slot of a " { $link secure-config } " can contain the path of a file with Diffie-Hellman key exchange parameters."
$nl
"This slot is required for secure server sockets." ;

ARTICLE: "ssl-ephemeral-rsa" "Ephemeral RSA key bits"
"The " { $snippet "ephemeral-key-bits" } " slot of a " { $link secure-config } " contains the length of the ephemeral RSA key, in bits."
$nl
"The default value is 1024, and anything less than that is considered insecure. This slot is required for secure server sockets." ;

ARTICLE: "ssl-config" "Secure socket configuration"
"Secure sockets require some configuration, particularly for server sockets. A class represents secure socket configuration parameters:"
{ $subsections secure-config }
"Creating new instances:"
{ $subsections <secure-config> }
"Configuration parameters:"
{ $subsections
    "ssl-methods"
    "ssl-key-file"
    "ssl-ca-file"
    "ssl-dh-file"
    "ssl-ephemeral-rsa"
} ;

HELP: <secure-context>
{ $values { "config" secure-config } { "context" secure-context } }
{ $description "Creates a new " { $link secure-context } ". This word should not usually be called directly, use " { $link with-secure-context } " instead." } ;

HELP: with-secure-context
{ $values { "config" secure-config } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope where a " { $link secure-context } " constructed from the specified configuration is available." } ;

ARTICLE: "ssl-contexts" "Secure socket contexts"
"All secure socket operations must be performed in a secure socket context. A context is created from a secure socket configuration. An implicit context with the default configuration is always available, however server sockets require a certificate to be set together with other parameters, and the default configuration is insufficient, so a context must be explicitly created in that case."
{ $subsections with-secure-context } ;

HELP: secure
{ $class-description "The class of secure socket addresses." } ;

HELP: <secure>
{ $values { "addrspec" "an address specifier" } { "hostname" { $maybe string } } { "secure" secure } }
{ $description "Creates a new secure socket address, which can then be passed to " { $link <client> } " or " { $link <server> } "." } ;

ARTICLE: "ssl-addresses" "Secure socket addresses"
"Secure socket connections are established by passing a secure socket address to " { $link <client> } " or " { $link <server> } "."
$nl
"Secure socket addresses form a class:"
{ $subsections secure }
"Constructing secure socket addresses:"
{ $subsections <secure> }
"Instances of this class can wrap an " { $link inet } ", " { $link inet4 } " or an " { $link inet6 } ", although note that certificate validation is only performed for instances of " { $link inet } " since otherwise the host name is not available." ;

HELP: send-secure-handshake
{ $contract "Upgrades the socket connection of the current " { $link with-client } " scope to a secure connection and initiates a SSL/TLS handshake." }
{ $errors "Throws " { $link upgrade-on-non-socket } " or " { $link upgrade-buffers-full } " if used improperly." }
{ $examples "This word is used by the " { $vocab-link "smtp" } " library to implement SMTP-TLS." } ;

HELP: accept-secure-handshake
{ $contract "Upgrades the socket connection stored in the " { $link input-stream } " and " { $link output-stream } " variables to a secure connection and waits for an SSL/TLS handshake." }
{ $errors "Throws " { $link upgrade-on-non-socket } " or " { $link upgrade-buffers-full } " if used improperly." } ;

ARTICLE: "ssl-upgrade" "Upgrading existing connections"
"Some protocols, such as HTTPS, require that the connection be established as an SSL/TLS connection. Others, such as secure SMTP and POP3 require that the client and server initiate an SSL/TLS handshake upon the client sending a plain-text request. The latter use-case is accommodated by a pair of words."
$nl
"Upgrading a connection to a secure socket by initiating an SSL/TLS handshake with the server:"
{ $subsections send-secure-handshake }
"Upgrading a connection to a secure socket by waiting for an SSL/TLS handshake from the client:"
{ $subsections accept-secure-handshake } ;

HELP: premature-close-error
{ $error-description "Thrown if an SSL connection is closed without the proper " { $snippet "close_notify" } " sequence." } ;

HELP: certificate-verify-error
{ $error-description "Thrown if certificate verification failed. The " { $snippet "result" } " slot contains an object identifying the low-level error that occurred." } ;

HELP: subject-name-verify-error
{ $error-description "Thrown during certificate verification if the subject names on the certificate does not match the host name the socket was connected to. This indicates a potential man-in-the-middle attack. The " { $slot "expected" } " and " { $slot "got" } " slots contain the mismatched host names." } ;

HELP: upgrade-on-non-socket
{ $error-description "Thrown if " { $link send-secure-handshake } " or " { $link accept-secure-handshake } " is called with the " { $link input-stream } " and " { $link output-stream } " variables not set to a socket. This error can also indicate that the connection has already been upgraded to a secure connection." } ;

HELP: upgrade-buffers-full
{ $error-description "Thrown if " { $link send-secure-handshake } " or " { $link accept-secure-handshake } " is called when there is still data which hasn't been read or written." }
{ $notes "Clients should ensure to " { $link flush } " their last command to the server before calling " { $link send-secure-handshake } "." } ;

HELP: no-tls-supported
{ $error-description "If you see this error, make sure you have all the necessary libraries installed (libssl and libcrypto) with at least one of " { $link "ssl-methods" } " supported." } ;

ARTICLE: "ssl-errors" "Secure socket errors"
"Secure sockets can throw one of several errors in addition to the usual I/O errors:"
{ $subsections
    premature-close-error
    certificate-verify-error
    subject-name-verify-error
}
"The " { $link send-secure-handshake } " word can throw one of two errors:"
{ $subsections
    upgrade-on-non-socket
    upgrade-buffers-full
} ;

ARTICLE: "io.sockets.secure" "Secure sockets (SSL, TLS)"
"The " { $vocab-link "io.sockets.secure" } " vocabulary implements secure, encrypted sockets using the OpenSSL library."
$nl
"On Windows make sure you have the appropriate DLLs available, e.g. libcrypto-37.dll and libssl-38.dll."
$nl
"This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit (" { $url "http://www.openssl.org/" } "), cryptographic software written by Eric Young (eay@cryptsoft.com) and software written by Tim Hudson (tjh@cryptsoft.com)."
{ $subsections
    "ssl-config"
    "ssl-contexts"
    "ssl-addresses"
    "ssl-upgrade"
    "ssl-errors"
} ;

ABOUT: "io.sockets.secure"
