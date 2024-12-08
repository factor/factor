USING: help.markup help.syntax math sequences ;

IN: base32

HELP: >base32
{ $values { "seq" sequence } { "base32" sequence } }
{ $description "Encode into Base32 encoding (RFC 3548)." } ;

HELP: base32>
{ $values { "base32" sequence } { "seq" sequence } }
{ $description "Decode from Base32 encoding (RFC 3548)." } ;

HELP: >base32hex
{ $values { "seq" sequence } { "base32" sequence } }
{ $description "Encode into Base32 encoding with Extended Hex Alphabet (RFC 4648)." } ;

HELP: base32hex>
{ $values { "base32" sequence } { "seq" sequence } }
{ $description "Decode from Base32 encoding with Extended Hex Alphabet (RFC 4648)." } ;

HELP: base32-crockford>
{ $values { "base32" sequence } { "n" integer } }
{ $description "Decode into Douglas Crockford's Base32 encoding." } ;

HELP: >base32-crockford
{ $values { "n" integer } { "base32" sequence } }
{ $description "Encode from Douglas Crockford's Base32 encoding." } ;

HELP: >zbase32
{ $values { "seq" sequence } { "zbase32" sequence } }
{ $description "Encode into the \"human-oriented\" Base32 encoding." } ;

HELP: zbase32>
{ $values { "zbase32" sequence } { "seq" sequence } }
{ $description "Decode from the \"human-oriented\" Base32 encoding." } ;

ARTICLE: "base32" "Base32 conversions"
"The " { $vocab-link "base32" } " vocabulary supports encoding and decoding of various Base32 encoding formats, including:"
$nl
"Base32 encoding (RFC 3548):"
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
}
"Human-oriented Base32 encoding, described in " { $url "http://philzimmermann.com/docs/human-oriented-base-32-encoding.txt" } ":"
{ $subsections
    >zbase32
    zbase32>
} ;

ABOUT: "base32"
