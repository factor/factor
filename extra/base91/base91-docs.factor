USING: help.markup help.syntax sequences ;
IN: base91

HELP: >base91
{ $values { "seq" sequence } { "base91" sequence } }
{ $description "Encode into Base 16 encoding." } ;

HELP: base91>
{ $values { "base91" sequence } { "seq" sequence } }
{ $description "Decode from Base 16 encoding." } ;

ARTICLE: "base91" "Base 91 conversions"
"The " { $vocab-link "base91" } " vocabulary supports encoding and decoding of the Base 91 format:"
$nl
{ $subsections
    >base91
    base91>
} ;

ABOUT: "base91"
