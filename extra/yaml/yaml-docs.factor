! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs byte-arrays hash-sets hashtables
help.markup help.syntax kernel linked-assocs math sequences sets
strings ;
IN: yaml

HELP: >yaml
{ $values
    { "obj" object }
    { "str" string }
}
{ $description "Serializes the object into a YAML formatted string with one document representing the object."  } ;

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

ARTICLE: "yaml-mapping" "Mapping between Factor and YAML types"
{ $heading "Types mapping" }
"The rules in the table below are used to convert between yaml and factor objects."
" They are based on " { $url "http://www.yaml.org/spec/1.2/spec.html" } ", section \"10.3. Core Schema\" and " { $url "http://yaml.org/type/" } ", adapted to factor's conventions."
{ $table
  { { $snippet "yaml" } { $snippet "factor" } }
  { { $snippet "scalars" } "" }
  { "!!null" { $link f } }
  { "!!bool" { $link boolean } }
  { "!!int" { $link integer } }
  { "!!float" { $link float } }
  { "!!str" { $link string } }
  { "!!binary" { $link byte-array } }
  { "!!timestamp" "Not supported yet" }
  { { $snippet "sequences" } "" }
  { "!!seq" { $link array } }
  { "!!omap" { $link linked-assoc } }
  { "!!pairs" { $link "alists" } }
  { { $snippet "mappings" } "" }
  { "!!map" { $link hashtable } }
  { "!!set" { $link hash-set } }
}

{ $heading "YAML to Factor Round Tripping" }
"The following YAML types are not preserved:"
{ $list
  { "!!null -> " { $link boolean } " -> !!bool" }
  { "!!pairs -> " { $link "alists" } " -> !!seq" }
}
{ $heading "Factor to YAML Round Tripping" }
"The following Factor types are not preserved, unless another type has precedence:"
{ $list
  { { $link assoc } " -> !!map -> " { $link hashtable } }
  { { $link set } " -> !!set -> " { $link hash-set } }
  { { $link sequence } " -> !!seq -> " { $link array } }
}
"Examples of type precedence which preserves type: " { $link byte-array } " over " { $link sequence } "."
;

ARTICLE: "yaml-output" "Serialization control"
"TODO allow to control the serialization details, for example"
{ $list
  "force explicit/implicit types"
  "force flow/block styles"
  "etc."
}
;
ARTICLE: "yaml-input" "Deserialization control"
"TODO, implement or drop the following features:"
{ $list
  "Activate/deactivate !!value"
  "Activate/deactivate !!merge ?"
  "Activate/deactivate YAML1.1 compatibility (ie boolean as On, OFF etc)"
  "select schema: \"failsafe\", \"JSON\", \"Core\" ?"
  "etc."
}
;
ARTICLE: "yaml" "YAML serialization"
"The " { $vocab-link "yaml" } " vocabulary implements YAML serialization/deserialization."
{ $heading "Main conversion words" }
{ $subsections
    >yaml
    >yaml-docs
    yaml>
    yaml-docs>
}
{ $heading "Next topics:" }
{ $subsections
"yaml-mapping"
"yaml-output"
"yaml-input"
}
{ $examples
  { $example "USING: prettyprint yaml ;"
"\"- true
- null
- ! 42
- \\\"42\\\"
- 42
- 0x2A
- 0o52
- 42.0
- 4.2e1\" yaml> ."
"{ t f \"42\" \"42\" 42 42 42 42.0 42.0 }"
 }
  { $example "USING: yaml ;"
"""{ t 32 "foobar" { "nested" "list" } H{ { "nested" "assoc" } } } >yaml print"""
    "--- !!seq\n- !!bool true\n- !!int 32\n- !!str foobar\n- !!seq\n  - !!str nested\n  - !!str list\n- !!map\n  !!str nested: !!str assoc\n...\n"
  }
}
;


{ >yaml >yaml-docs } related-words
{ yaml> yaml-docs> } related-words

ABOUT: "yaml"
