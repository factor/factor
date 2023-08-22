! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs byte-arrays hash-sets hashtables calendar
help.markup help.syntax kernel linked-assocs math sequences sets
strings yaml.ffi yaml.config yaml.conversion ;
IN: yaml

HELP: >yaml
{ $values
    { "obj" object }
    { "str" string }
}
{ $description "Serializes the object into a YAML formatted string with one document representing the object." } ;

HELP: >yaml-docs
{ $values
    { "seq" sequence }
    { "str" string }
}
{ $description "Serializes the sequence into a YAML formatted string. Each element is output as a YAML document." } ;

HELP: yaml-docs>
{ $values
    { "str" string }
    { "arr" array }
}
{ $description "Deserializes the YAML formatted string into a Factor array. Each document becomes an element of the array." } ;

HELP: yaml>
{ $values
    { "str" string }
    { "obj" object }
}
{ $description "Deserializes the YAML formatted string into a Factor object. Throws "
{ $link yaml-no-document } " when there is no document (for example the empty string)."
$nl
}
{ $notes
"Contrary to " { $link yaml-docs> } ", this word only parses the input until one document is produced."
" Valid or invalid content after the first document is ignored."
" To verifiy that the whole input is one valid YAML document, use "
{ $link yaml-docs> } " and assert that the length of the output array is 1."
}
;

HELP: libyaml-emitter-error
{ $values
    { "error" yaml_error_type_t } { "problem" string }
}
{ $description "yaml_emitter_emit returned with status 0. The slots of this error give more information." } ;

HELP: libyaml-initialize-error
{ $description "yaml_*_initialize returned with status 0. This usually means LibYAML failed to allocate memory." } ;

HELP: libyaml-parser-error
{ $values
    { "error" yaml_error_type_t } { "problem" string } { "problem_offset" integer } { "problem_value" integer } { "problem_mark" yaml_mark_t } { "context" string } { "context_mark" yaml_mark_t }
}
{ $description "yaml_parser_parse returned with status 0. The slots of this error give more information." } ;

HELP: yaml-no-document
{ $description "The input of " { $link yaml> } " had no documents." } ;

HELP: yaml-undefined-anchor
{ $values
    { "anchor" string } { "anchors" sequence }
}
{ $description "The document references an undefined anchor " { $snippet "anchor" } ". For information, the list of currently defined anchors in the document is " { $snippet "anchors" } "." } ;

HELP: yaml-unexpected-event
{ $values
    { "actual" yaml_event_type_t } { "expected" sequence }
}
{ $description "LibYAML produced the unexpected event " { $snippet "actual" } ", but the list of expected events is " { $snippet "expected" } "." } ;

HELP: ?apply-merge-key
{ $values
    { "assoc" assoc }
    { "assoc'" assoc }
}
{ $description "Merges the value of the !!merge key in " { $snippet "assoc" } } ;
{ merge ?apply-merge-key } related-words
{ value scalar-value } related-words

HELP: scalar-value
{ $values
    { "obj" object }
    { "obj'" object }
}
{ $description "If " { $snippet "obj" } " is hashtable, returns it's default value, else return " { $snippet "obj" } " itself." } ;

ARTICLE: "yaml-mapping" "Mapping between Factor and YAML types"
{ $heading "Types mapping" }
"The rules in the table below are used to convert between yaml and factor objects."
" They are based on " { $url "https://www.yaml.org/spec/1.2/spec.html" } ", section \"10.3. Core Schema\" and " { $url "https://yaml.org/type/" } ", adapted to factor's conventions."
{ $table
  { { $snippet "yaml" } { $snippet "factor" } }
  { { $snippet "scalars" } "" }
  { "!!null" { $link f } }
  { "!!bool" { $link boolean } }
  { "!!int" { $link integer } }
  { "!!float" { $link float } }
  { "!!str" { $link string } }
  { "!!binary" { $link byte-array } }
  { "!!timestamp" { $link timestamp } }
  { { $snippet "sequences" } "" }
  { "!!seq" { $link array } }
  { "!!omap" { $link linked-assoc } }
  { "!!pairs" { $link "alists" } }
  { { $snippet "mappings" } "" }
  { "!!map" { $link hashtable } }
  { "!!set" { $link hash-set } }
  { { $snippet "special keys" } "" }
  { "!!merge" { $link yaml-merge } }
  { "!!value" { $link yaml-value } }
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

ARTICLE: "yaml-errors" "YAML errors"
{ $heading "libYAML's errors" }
"LibYAML exposes error when parsing/emitting yaml. See " { $url "https://pyyaml.org/wiki/LibYAML" } ". More information is available directly in pyyaml's source code in their C interface. They are groupped in the following errors:"
{ $list
  { $link libyaml-parser-error }
  { $link libyaml-emitter-error }
  { $link libyaml-initialize-error }
}
{ $heading "Conversion errors" }
"Additional errors are thrown when converting to/from factor objects:"
{ $list
  { $link yaml-undefined-anchor }
  { $link yaml-no-document }
  "Or many errors thrown by library words (eg unparseable numbers, converting unsupported objects to yaml, etc)"
}
{ $heading "Bugs" }
"The following error probably means that there is a bug in the implementation: " { $link yaml-unexpected-event }
;

ARTICLE: "yaml-keys" "Special mapping keys"
"The following special keys have been implemented for !!map. By default, these keys will be taken into account when deserializing yaml documents. To keep the original document structure, configuration variables can be set. See " { $link "yaml-config" } "."
{ $heading "!!merge" }
"See " { $url "https://yaml.org/type/merge.html" } $nl
"As per " { $url "https://sourceforge.net/p/yaml/mailman/message/12308050" }
", the merge key is implemented bottom up:" $nl
{ $unchecked-example "USING: yaml prettyprint ;
\"
foo: 1
<<:
  bar: 2
  <<:
    baz: 3
\" yaml> ."
"H{ { \"baz\" 3 } { \"foo\" 1 } { \"bar\" 2 } }" }
{ $heading "!!value" }
"See " { $url "https://yaml.org/type/value.html" } $nl
{ $unchecked-example "USING: yaml prettyprint ;
\"
---     # Old schema
link with:
  - library1.dll
  - library2.dll
---     # New schema
link with:
  - = : library1.dll
    version: 1.2
  - = : library2.dll
    version: 2.3
\" yaml-docs> ."
"{
    H{ { \"link with\" { \"library1.dll\" \"library2.dll\" } } }
    H{ { \"link with\" { \"library1.dll\" \"library2.dll\" } } }
}"
}

;
ARTICLE: "yaml" "YAML serialization"
"The " { $vocab-link "yaml" } " vocabulary implements YAML serialization/deserialization. It uses LibYAML, a YAML parser and emitter written in C (" { $url "https://pyyaml.org/wiki/LibYAML" } ")."
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
"yaml-keys"
"yaml-errors"
"yaml-config"
}
{ $examples
  { $heading "Input" }
  { $unchecked-example "USING: prettyprint yaml ;"
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
{ $heading "Output -- human readable" }
  { $unchecked-example "USING: yaml yaml.config ;"
"t implicit-tags set
t implicit-start set
t implicit-end set
+libyaml-default+ emitter-canonical set
+libyaml-default+ emitter-indent set
+libyaml-default+ emitter-width set
+libyaml-default+ emitter-line-break set
t emitter-unicode set
"
"{
  H{
    { \"name\" \"Mark McGwire\" }
    { \"hr\" 65 }
    { \"avg\" 0.278 }
  }
  H{
    { \"name\" \"Sammy Sosa\" }
    { \"hr\" 63 }
    { \"avg\" 0.288 }
  }
} >yaml print"
    "- name: Mark McGwire
  hr: 65
  avg: 0.278
- name: Sammy Sosa
  hr: 63
  avg: 0.288
"
  }
{ $heading "Output -- verbose" }
  { $unchecked-example "USING: yaml yaml.config ;"
"f implicit-tags set
f implicit-start set
f implicit-end set
+libyaml-default+ emitter-canonical set
+libyaml-default+ emitter-indent set
+libyaml-default+ emitter-width set
+libyaml-default+ emitter-line-break set
t emitter-unicode set

{ t 32 \"foobar\" { \"nested\" \"list\" } H{ { \"nested\" \"assoc\" } } } >yaml print"
    "--- !!seq\n- !!bool true\n- !!int 32\n- !!str foobar\n- !!seq\n  - !!str nested\n  - !!str list\n- !!map\n  !!str nested: !!str assoc\n...\n"
  }
}
;


{ >yaml >yaml-docs } related-words
{ yaml> yaml-docs> } related-words

ABOUT: "yaml"
