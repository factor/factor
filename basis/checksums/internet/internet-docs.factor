USING: help.markup help.syntax ;
IN: checksums.internet

HELP: internet
{ $class-description "Internet (RFC1071) checksum algorithm." } ;

ARTICLE: "checksums.internet" "Internet checksum"
"The internet checksum algorithm implements RFC1071."
{ $subsections internet }
"For more information, see these RFC's:"
$nl
{ $url "http://www.ietf.org/rfc/rfc1071.txt" }
$nl
{ $url "http://www.ietf.org/rfc/rfc1141.txt" } ;

ABOUT: "checksums.internet"
