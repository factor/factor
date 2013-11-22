USING: help.markup help.syntax ;
IN: checksums.fletcher

HELP: fletcher-16
{ $class-description "Fletcher's 16-bit checksum algorithm." } ;

HELP: fletcher-32
{ $class-description "Fletcher's 32-bit checksum algorithm." } ;

HELP: fletcher-64
{ $class-description "Fletcher's 64-bit checksum algorithm." } ;

ARTICLE: "checksums.fletcher" "Fletcher's checksum"
"The Fletcher checksum is an algorithm for computing a position-dependent checksum devised by John G. Fletcher at Lawrence Livermore Labs in the late 1970s."
{ $subsections fletcher-16 fletcher-32 fletcher-64 } ;

ABOUT: "checksums.fletcher"
