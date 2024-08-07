USING: help.markup help.syntax sequences ;
IN: base16

HELP: >base16
{ $values { "seq" sequence } { "base16" sequence } }
{ $description "Encode into Base16 encoding." } ;

HELP: base16>
{ $values { "base16" sequence } { "seq" sequence } }
{ $description "Decode from Base16 encoding." } ;

ARTICLE: "base16" "Base16 conversions"
"The " { $vocab-link "base16" } " vocabulary supports encoding and decoding of the Base16 format:"
$nl
{ $subsections
    >base16
    base16>
} ;

ABOUT: "base16"
