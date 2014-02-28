! Copyright (C) 2014 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.data classes.struct combinators
continuations destructors io.encodings.string io.encodings.utf8
kernel libc locals prettyprint sequences yaml.ffi ;
IN: yaml.dbg

: event. ( event -- )
  dup [ data>> ] [ type>> ] bi* {
    { YAML_STREAM_START_EVENT [ stream_start>>  ] }
    { YAML_DOCUMENT_START_EVENT [ document_start>> ] }
    { YAML_DOCUMENT_END_EVENT [ document_end>> ] }
    { YAML_ALIAS_EVENT [ alias>> ] }
    { YAML_SCALAR_EVENT [ scalar>> ] }
    { YAML_SEQUENCE_START_EVENT [ sequence_start>> ] }
    { YAML_MAPPING_START_EVENT [ mapping_start>> ] }
    [ nip ]
  } case . ;
:: yaml-events ( string -- )
[
yaml_parser_t (malloc-struct) &free &yaml_parser_delete :> parser
parser yaml_parser_initialize .

string utf8 encode [ malloc-byte-array &free ] [ length ] bi :> ( input length )
parser input length yaml_parser_set_input_string

yaml_event_t (malloc-struct) &free :> event

f :> done!
[
  [ done ] [
    parser event yaml_parser_parse 0 = [
      "error" throw
    ] [ [
        event &yaml_event_delete event.
        event type>> YAML_STREAM_END_EVENT = done!
    ] with-destructors ] if
  ] until
] [ . ] recover

] with-destructors

;
