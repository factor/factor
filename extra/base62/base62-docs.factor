USING: help.markup help.syntax sequences ;
IN: base62

HELP: >base62
{ $values { "seq" sequence } { "base62" sequence } }
{ $description "Encode into Base 16 encoding." } ;

HELP: base62>
{ $values { "base62" sequence } { "seq" sequence } }
{ $description "Decode from Base 16 encoding." } ;

ARTICLE: "base62" "Base 62 conversions"
"The " { $vocab-link "base62" } " vocabulary supports encoding and decoding of the Base 62 format:"
$nl
{ $subsections
    >base62
    base62>
} ;

ABOUT: "base62"
