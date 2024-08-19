USING: help.markup help.syntax math sequences ;

IN: base45

HELP: >base45
{ $values { "seq" sequence } { "base45" sequence } }
{ $description "Encode into Base45 encoding (RFC 3548)." } ;

HELP: base45>
{ $values { "base45" sequence } { "seq" sequence } }
{ $description "Decode from Base45 encoding (RFC 3548)." } ;

ARTICLE: "base45" "Base45 conversions"
"The " { $vocab-link "base45" } " vocabulary supports encoding and decoding of the Base45 format:"
$nl
"Base45 encoding (RFC 9285):"
{ $subsections
    >base45
    base45>
}
;

ABOUT: "base45"
