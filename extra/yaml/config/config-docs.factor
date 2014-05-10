! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax yaml.ffi ;
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
"The following variables control the YAML serialization/deserialization: "
{ $subsections
  emitter-canonical
  emitter-indent
  emitter-line-break
  emitter-unicode
  emitter-width
}
"Using libyaml's default values: " { $link +libyaml-default+ }
;

ABOUT: "yaml-config"
