USING: help.markup help.syntax sequences ;
IN: base24

HELP: >base24
{ $values { "seq" sequence } { "base24" sequence } }
{ $description "Encode into Base 16 encoding." } ;

HELP: base24>
{ $values { "base24" sequence } { "seq" sequence } }
{ $description "Decode from Base 16 encoding." } ;

ARTICLE: "base24" "Base 24 conversions"
"The " { $vocab-link "base24" } " vocabulary supports encoding and decoding of the Base 24 format:"
$nl
{ $subsections
    >base24
    base24>
} ;

ABOUT: "base24"
