USING: help.markup help.syntax kernel math sequences quotations
crypto.common byte-arrays ;
IN: crypto.md5

HELP: stream>md5
{ $values { "stream" "a stream" } { "byte-array" "md5 hash" } }
{ $description "Take the MD5 hash until end of stream." }
{ $notes "Used to implement " { $link byte-array>md5 } " and " { $link file>md5 } ".  Call " { $link hex-string } " to convert to the canonical string representation." } ;

HELP: byte-array>md5
{ $values { "byte-array" byte-array } { "checksum" "an md5 hash" } }
{ $description "Outputs the MD5 hash of a byte array." }
{ $notes "Call " { $link hex-string } " to convert to the canonical string representation." } ;

HELP: file>md5
{ $values { "path" "a path" } { "byte-array" "byte-array md5 hash" } }
{ $description "Outputs the MD5 hash of a file." }
{ $notes "Call " { $link hex-string } " to convert to the canonical string representation." } ;
