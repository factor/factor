USING: help.markup help.syntax ;
IN: checksums.sha

HELP: sha-224
{ $class-description "SHA-224 checksum algorithm." } ;

HELP: sha-256
{ $class-description "SHA-256 checksum algorithm." } ;

ARTICLE: "checksums.sha" "SHA-2 checksum"
"The SHA family of checksum algorithms are one-way hashes useful for checksumming data. SHA-1 is considered insecure, while SHA-2 It is generally considered to be pretty strong." $nl
"SHA-2 checksums:"
{ $subsection sha-224 }
{ $subsection sha-256 }
"SHA-1 checksum:"
{ $subsection sha1 } ;

ABOUT: "checksums.sha"
