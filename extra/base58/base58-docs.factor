USING: help.markup help.syntax sequences ;
IN: base58

HELP: >base58
{ $values { "seq" sequence } { "base58" sequence } }
{ $description "Encode into Base 16 encoding." } ;

HELP: base58>
{ $values { "base58" sequence } { "seq" sequence } }
{ $description "Decode from Base 16 encoding." } ;

ARTICLE: "base58" "Base 58 conversions"
"The " { $vocab-link "base58" } " vocabulary supports encoding and decoding of the Base 58 format:"
$nl
{ $subsections
    >base58
    base58>
} ;

ABOUT: "base58"
