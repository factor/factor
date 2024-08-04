USING: help.markup help.syntax math sequences ;

IN: base32

HELP: >base32
{ $values { "seq" sequence } { "base32" sequence } }
{ $description "Encode into Base 32 encoding (RFC 3548)." } ;

HELP: base32>
{ $values { "base32" sequence } { "seq" sequence } }
{ $description "Decode from Base 32 encoding (RFC 3548)." } ;

HELP: >base32hex
{ $values { "seq" sequence } { "base32" sequence } }
{ $description "Encode into Base 32 encoding with Extended Hex Alphabet (RFC 4648)." } ;

HELP: base32hex>
{ $values { "base32" sequence } { "seq" sequence } }
{ $description "Decode from Base 32 encoding with Extended Hex Alphabet (RFC 4648)." } ;

HELP: base32-crockford>
{ $values { "base32" sequence } { "n" integer } }
{ $description "Decode into Douglas Crockford's Base 32 encoding." } ;

HELP: >base32-crockford
{ $values { "n" integer } { "base32" sequence } }
{ $description "Encode from Douglas Crockford's Base 32 encoding." } ;

ARTICLE: "base32" "Base 32 conversions"
"The " { $vocab-link "base32" } " vocabulary supports encoding and decoding of various Base32 encoding formats, including:"
$nl
"Base 32 encoding (RFC 3548):"
{ $subsections
    >base32
    base32>
}
"Base32 encoding with Extended Hex Alphabet (RFC 4648):"
{ $subsections
    >base32hex
    base32hex>
}
"Douglas Crockford's Base32 encoding:"
{ $subsections
    >base32-crockford
    base32-crockford>
    >base32-crockford-checksum
    base32-crockford-checksum>
} ;

ABOUT: "base32"
