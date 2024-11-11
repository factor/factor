USING: help.markup help.syntax kernel sequences ;
IN: bech32

HELP: >bech32
{ $values { "hrp" object } { "data" sequence } { "bech32" sequence } }
{ $description "Encode into Bech32 encoding." } ;

HELP: bech32>
{ $values { "bech32" sequence } { "hrp" object } { "data" sequence } }
{ $description "Decode from Bech32 encoding." } ;

HELP: >bech32m
{ $values { "hrp" object } { "data" sequence } { "bech32m" sequence } }
{ $description "Encode into Bech32m encoding." } ;

HELP: bech32m>
{ $values { "bech32m" sequence } { "hrp" object } { "data" sequence } }
{ $description "Decode from Bech32m encoding." } ;

ARTICLE: "bech32" "Bech32 conversions"
"The " { $vocab-link "bech32" } " vocabulary supports encoding and decoding of the Bech32 format:"
$nl
{ $subsections
    >bech32
    bech32>
    >bech32m
    bech32m>
} ;

ABOUT: "bech32"
