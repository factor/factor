! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax yaml.ffi yaml.conversion ;
IN: yaml.config

HELP: +libyaml-default+
{ $var-description "Setting a variable in the following list to " { $link +libyaml-default+ } " leaves libyaml's default options:" }
{ $subsections
  emitter-canonical
  emitter-indent
  emitter-line-break
  emitter-unicode
  emitter-width
} ;

HELP: emitter-canonical
{ $var-description "If set, " { $link yaml_emitter_set_canonical } " is called with the value of this variable at the beginning of each document." } ;

HELP: emitter-indent
{ $var-description "If set, " { $link yaml_emitter_set_indent } " is called with the value of this variable at the beginning of each document." } ;

HELP: emitter-line-break
{ $var-description "If set, " { $link yaml_emitter_set_break } " is called with the value of this variable at the beginning of each document." } ;

HELP: emitter-unicode
{ $var-description "If set, " { $link yaml_emitter_set_unicode } " is called with the value of this variable at the beginning of each document." } ;

HELP: emitter-width
{ $var-description "If set, " { $link yaml_emitter_set_width } " is called with the value of this variable at the beginning of each document." } ;

ARTICLE: "yaml-config" "YAML control variables"
{ $subsections
  "yaml-input"
  "yaml-output"
}
;

ARTICLE: "yaml-input" "YAML deserialization control"
"The following variables control the YAML deserialization process:"
{ $heading "Special Keys" }
{ $subsections
  value
  merge
} ;
ARTICLE: "yaml-output" "YAML serialization control"
"The following variables control the YAML serialization process:"
{ $heading "LibYAML's emitter:" }
{ $subsections
  emitter-canonical
  emitter-indent
  emitter-line-break
  emitter-unicode
  emitter-width
}
"Using libyaml's default values: " { $link +libyaml-default+ }
{ $heading "Tags" }
{ $subsections
  implicit-tags
}
{ $heading "Document markers" }
{ $subsections
  implicit-start
  implicit-end
}
;

HELP: implicit-tags
{ $var-description "When this is set, tags are omitted during serialization when it safe to do so. For example, 42 can be safely serialized as \"42\", but \"42\" must be serialized as \"'42'\" or \"\"42\"\" or \"!!str 42\". This uses the " { $snippet "implicit" } " parameter of " { $link yaml_scalar_event_initialize } ", " { $link yaml_sequence_start_event_initialize } " and " { $link yaml_mapping_start_event_initialize } "."
} ;

HELP: implicit-start
{ $var-description "The \""
{ $snippet "implicit" } "\" parameter of " { $link yaml_document_start_event_initialize } ". Changing this variable is always safe and produces valid YAML documents because LibYAML ignores it when it would be invalid (for example, when there are multiple documents in a stream)." }
;

HELP: implicit-end
{ $var-description "The \""
{ $snippet "implicit" } "\" parameter of " { $link yaml_document_end_event_initialize } ". Changing this variable is always safe and produces valid YAML documents because LibYAML ignores it when it would be invalid (for example, when there are multiple documents in a stream)." }
;

{ implicit-start implicit-end } related-words

HELP: merge
{ $var-description "If false, deserialized yaml documents will contain instances of " { $link yaml-merge } " for !!merge keys and the value associated with this key will not be merged into the enclosing mapping. You can then call ?apply-merge-key on such a mapping to perform the merge." } ;

HELP: value
{ $var-description "If false, deserialized yaml documents will contain instances of " { $link yaml-value } " for !!value keys and the value associated with this key will replace the enclosing mapping. You can then call scalar-value on such a mapping to get the default value." } ;
ABOUT: "yaml-config"
{ yaml-merge merge } related-words
{ yaml-value value } related-words
