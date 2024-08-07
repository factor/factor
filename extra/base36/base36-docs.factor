USING: help.markup help.syntax sequences ;
IN: base36

HELP: >base36
{ $values { "seq" sequence } { "base36" sequence } }
{ $description "Encode into Base36 encoding." } ;

HELP: base36>
{ $values { "base36" sequence } { "seq" sequence } }
{ $description "Decode from Base36 encoding." } ;

ARTICLE: "base36" "Base36 conversions"
"The " { $vocab-link "base36" } " vocabulary supports encoding and decoding of the Base36 format:"
$nl
{ $subsections
    >base36
    base36>
} ;

ABOUT: "base36"
