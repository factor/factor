USING: help.markup help.syntax ;
IN: io.sockets.secure.openssl


HELP: subject-name
{ $values { "certificate" "an SSL peer certificate" } }
{ $description "The subject name of a certificate." } ;

HELP: subject-names-match?
{ $values { "host" "a host name" } { "subject" "a subject name" } }
{ $description "True if the host name matches the subject name." }
{ $examples
    { $code
        "\"www.google.se\" \"*.google.se\" subject-names-match?"
        "t"
    }
} ;

HELP: alternative-dns-names
{ $values { "certificate" "an SSL peer certificate" } }
{ $description "Alternative subject names for the certificate." } ;
