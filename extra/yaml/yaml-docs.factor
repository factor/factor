! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs help.markup help.syntax kernel sequences
strings ;
IN: yaml

HELP: >yaml
{ $values
    { "obj" object }
    { "str" string }
}
{ $description "Serializes the object into a YAML formatted string." } ;

HELP: >yaml-docs
{ $values
    { "seq" sequence }
    { "str" string }
}
{ $description "Serializes the sequence into a YAML formatted string. Each element is outputted as a YAML document" } ;

HELP: yaml-docs>
{ $values
    { "str" string }
    { "arr" array }
}
{ $description "Deserializes the YAML formatted string into a Factor array. Each document becomes an element of the array" } ;

HELP: yaml>
{ $values
    { "str" string }
    { "obj" object }
}
{ $description "Deserializes the YAML formatted string into a Factor object." } ;

ARTICLE: "yaml" "YAML serialization"
"The " { $vocab-link "yaml" } " vocabulary implements YAML serialization/deserialization."
{ $subsections
    >yaml
    >yaml-docs
    yaml>
    yaml-docs>
}
;

{ >yaml >yaml-docs } related-words
{ yaml> yaml-docs> } related-words

ABOUT: "yaml"
