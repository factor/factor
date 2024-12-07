USING: help.markup help.syntax sequences ;
IN: base92

HELP: >base92
{ $values { "seq" sequence } { "base92" sequence } }
{ $description "Encode into Base92 encoding." } ;

HELP: base92>
{ $values { "base92" sequence } { "seq" sequence } }
{ $description "Decode from Base92 encoding." } ;

ARTICLE: "base92" "Base92 conversions"
"The " { $vocab-link "base92" } " vocabulary supports encoding and decoding of the Base92 format:"
$nl
{ $subsections
    >base92
    base92>
} ;

ABOUT: "base92"
