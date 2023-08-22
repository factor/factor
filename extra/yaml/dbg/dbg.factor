! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data assocs classes.struct
combinators continuations destructors io io.backend
io.encodings.ascii io.encodings.string io.encodings.utf8
io.launcher kernel libc math.parser prettyprint sequences
yaml.ffi yaml.private ;
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
                parser event yaml_parser_parse [ [
                    event &yaml_event_delete event.
                    event type>> YAML_STREAM_END_EVENT = done!
                ] with-destructors ] [
                    parser (libyaml-parser-error)
                ] if
            ] until
        ] [ . ] recover
    ] with-destructors ;

: factor-struct-sizes ( -- arr )
    {
        yaml_version_directive_t
        yaml_tag_directive_t
        yaml_mark_t
        stream_start_token_data
        alias_token_data
        anchor_token_data
        tag_token_data
        scalar_token_data
        version_directive_token_data
        yaml_token_t
        stream_start_event_data
        tag_directives_document_start_event_data
        document_start_event_data
        document_end_event_data
        alias_event_data
        scalar_event_data
        sequence_start_event_data
        mapping_start_event_data
        yaml_event_t
        yaml_node_pair_t
        scalar_node_data
        sequence_node_data_items
        sequence_node_data
        mapping_node_data_pairs
        mapping_node_data
        yaml_node_t
        yaml_document_nodes
        yaml_document_tag_directives
        yaml_document_t
        yaml_simple_key_t
        yaml_alias_data_t
        string_yaml_parser_input
        yaml_parser_buffer
        yaml_parser_raw_buffer
        yaml_parser_tokens
        yaml_parser_indents
        yaml_parser_simple_keys
        yaml_parser_states
        yaml_parser_marks
        yaml_parser_tag_directives
        yaml_parser_aliases
        yaml_parser_t
        yaml_emitter_output_string
        yaml_emitter_buffer
        yaml_emitter_raw_buffer
        yaml_emitter_states
        yaml_emitter_events
        yaml_emitter_indents
        yaml_emitter_tag_directives
        yaml_emitter_anchor_data
        yaml_emitter_tag_data
        yaml_emitter_scalar_data
        yaml_emitter_anchors
        yaml_emitter_t
    } [ heap-size ] map ;

: c-struct-sizes ( -- sizes )
    "vocab:yaml/dbg/structs" normalize-path
    ascii <process-reader> stream-lines
    [ string>number ] map ;

: struct-sizes-dbg ( -- )
    c-struct-sizes factor-struct-sizes
    zip [ first2 = not ] find . . ;
