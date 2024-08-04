USING: help.markup help.syntax sequences ;
IN: base36

HELP: >base36
{ $values { "seq" sequence } { "base36" sequence } }
{ $description "Encode into Base 16 encoding." } ;

HELP: base36>
{ $values { "base36" sequence } { "seq" sequence } }
{ $description "Decode from Base 16 encoding." } ;

ARTICLE: "base36" "Base 36 conversions"
"The " { $vocab-link "base36" } " vocabulary supports encoding and decoding of the Base 36 format:"
$nl
{ $subsections
    >base36
    base36>
} ;

ABOUT: "base36"
