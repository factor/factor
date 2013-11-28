USING: help.markup help.syntax kernel strings sequences ;
IN: io.sockets.secure.openssl

HELP: subject-name
{ $values { "certificate" "an SSL peer certificate" } { "host" string } }
{ $description "The subject name of a certificate." } ;

HELP: subject-names-match?
{ $values { "host" "a host name" } { "subject" "a subject name" } { "?" boolean } }
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
