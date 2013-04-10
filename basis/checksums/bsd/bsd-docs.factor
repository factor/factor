USING: help.markup help.syntax ;
IN: checksums.bsd

HELP: bsd
{ $class-description "BSD checksum algorithm." } ;

ARTICLE: "checksums.bsd" "BSD checksum"
"The BSD checksum algorithm implements simple and fast 16-bit checksum. It is a commonly used, legacy checksum algorithm implemented in BSD and available through the GNU " { $snippet "sum" } " utility."
{ $subsections bsd } ;

ABOUT: "checksums.bsd"
