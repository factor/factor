! Copyright (C) 2013 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays assocs byte-arrays
classes.struct combinators combinators.extras
combinators.short-circuit destructors fry generalizations
hashtables hashtables.identity io.encodings.string
io.encodings.utf8 kernel libc linked-assocs make math
math.parser namespaces sequences sets strings yaml.config
yaml.conversion yaml.ffi hash-sets.identity ;
IN: yaml

ERROR: libyaml-parser-error
    error problem problem_offset
    problem_value problem_mark context context_mark ;
ERROR: libyaml-initialize-error ;
ERROR: libyaml-emitter-error error problem ;

ERROR: yaml-undefined-anchor anchor anchors ;
ERROR: yaml-unexpected-event actual expected ;
ERROR: yaml-no-document ;

<PRIVATE

: yaml-initialize-assert-ok ( ? -- )
    [ libyaml-initialize-error ] unless ;

: (libyaml-parser-error) ( parser -- )
    {
        [ error>> ]
        [ problem>> ]
        [ problem_offset>> ]
        [ problem_value>> ]
        [ problem_mark>> ]
        [ context>> ]
        [ context_mark>> ]
    } cleave [ clone ] 7 napply libyaml-parser-error ;

: (libyaml-emitter-error) ( emitter -- )
    [ error>> ] [ problem>> ] bi [ clone ] bi@ libyaml-emitter-error ;

: yaml-parser-assert-ok ( ? parser -- )
    swap [ drop ] [ (libyaml-parser-error) ] if ;

: yaml-emitter-assert-ok ( ? emitter -- )
    swap [ drop ] [ (libyaml-emitter-error) ] if ;

: yaml_parser_parse_asserted ( parser event -- )
    [ yaml_parser_parse ] [ drop yaml-parser-assert-ok ] 2bi ;

: yaml_emitter_emit_asserted ( emitter event -- )
    [ yaml_emitter_emit ] [ drop yaml-emitter-assert-ok ] 2bi ;

TUPLE: yaml-alias anchor ;
C: <yaml-alias> yaml-alias

SYMBOL: anchors

: ?register-anchor ( obj event -- obj )
    dupd anchor>> [ anchors get set-at ] [ drop ] if* ;

: assert-anchor-exists ( anchor -- )
    anchors get 2dup at* nip
    [ 2drop ] [ yaml-undefined-anchor ] if ;

: deref-anchor ( event -- obj )
    data>> alias>> anchor>>
    [ assert-anchor-exists ]
    [ <yaml-alias> ] bi ;

: event>scalar ( mapping-key? event -- obj )
    data>> scalar>>
    [ swap construct-scalar ]
    [ ?register-anchor ] bi ;

! TODO simplify this ?!?
TUPLE: factor_sequence_start_event_data anchor tag implicit style ;
TUPLE: factor_mapping_start_event_data anchor tag implicit style ;
TUPLE: factor_event_data sequence_start mapping_start ;
TUPLE: factor_yaml_event_t type data start_mark end_mark ;

: deep-copy-seq ( data -- data' )
    {
        [ anchor>> clone ]
        [ tag>> clone ]
        [ implicit>> ]
        [ style>> ]
    } cleave factor_sequence_start_event_data boa ;

: deep-copy-map ( data -- data' )
    {
        [ anchor>> clone ]
        [ tag>> clone ]
        [ implicit>> ]
        [ style>> ]
    } cleave factor_mapping_start_event_data boa ;

: deep-copy-data ( event -- data )
    [ data>> ] [ type>> ] bi {
        { YAML_SEQUENCE_START_EVENT [ sequence_start>> deep-copy-seq f ] }
        { YAML_MAPPING_START_EVENT [ mapping_start>> deep-copy-map f swap ] }
    } case factor_event_data boa ;

: deep-copy-event ( event -- event' )
    {
        [ type>> ]
        [ deep-copy-data ]
        [ start_mark>> ]
        [ end_mark>> ]
    } cleave factor_yaml_event_t boa ;

: (?scalar-value) ( mapping-key? event -- scalar/event scalar? )
    dup type>> {
        { YAML_SCALAR_EVENT [ event>scalar t ] }
        { YAML_ALIAS_EVENT [ nip deref-anchor t ] }
        [ drop nip deep-copy-event f ]
    } case ;
: ?mapping-key-scalar-value ( event -- scalar/event scalar? ) t swap (?scalar-value) ;
: ?scalar-value ( event -- scalar/event scalar? ) f swap (?scalar-value) ;

! Must not reuse the event struct before with-destructors scope ends
: next-event ( parser event -- event )
    [ yaml_parser_parse_asserted ] [ &yaml_event_delete ] bi ;

DEFER: parse-sequence
DEFER: parse-mapping

: (parse-sequence) ( parser event prev-event -- obj )
    data>> sequence_start>> [ [ 2drop f ] dip ?register-anchor drop ]
    [ [ parse-sequence ] [ construct-sequence ] bi* ] [ 2nip ?register-anchor ] 3tri ;

: (parse-mapping) ( parser event prev-event -- obj )
    data>> mapping_start>> [ [ 2drop f ] dip ?register-anchor drop ]
    [ [ parse-mapping ] [ construct-mapping ] bi* ] [ 2nip ?register-anchor ] 3tri ;

: next-complex-value ( parser event prev-event -- obj )
    dup type>> {
        { YAML_SEQUENCE_START_EVENT [ (parse-sequence) ] }
        { YAML_MAPPING_START_EVENT [ (parse-mapping) ] }
    } case ;

:: next-value ( parser event -- obj )
    parser event [ next-event ?scalar-value ] with-destructors
    [ [ parser event ] dip next-complex-value ] unless ;

:: parse-mapping ( parser event -- map )
    [
        f :> done!
        [ done ] [
            [
                parser event next-event type>>
                YAML_MAPPING_END_EVENT = [
                    t done! f f
                ] [
                    event ?mapping-key-scalar-value
                ] if
            ] with-destructors
            done [ 2drop ] [
                [ [ parser event ] dip next-complex-value ] unless
                parser event next-value swap ,,
            ] if
        ] until
    ] H{ } make ;

:: parse-sequence ( parser event  -- seq )
    [
        f :> done!
        [ done ] [
            [
                parser event next-event type>>
                YAML_SEQUENCE_END_EVENT = [
                    t done! f f
                ] [
                    event ?scalar-value
                ] if
            ] with-destructors
            done [ 2drop ] [
                [ [ parser event ] dip next-complex-value ] unless ,
            ] if
        ] until
    ] { } make ;

: expect-event ( parser event type -- )
    [
        [ next-event type>> ] dip 2dup =
        [ 2drop ] [ 1array yaml-unexpected-event ] if
    ] with-destructors ;

GENERIC: (deref-aliases) ( anchors obj -- obj' )

M: object (deref-aliases) nip ;

M: byte-array (deref-aliases) nip ;

M: string (deref-aliases) nip ;

M: yaml-alias (deref-aliases) anchor>> of ;

M: sequence (deref-aliases)
    [ (deref-aliases) ] with map! ;

M: sets:set (deref-aliases)
    [ members (deref-aliases) ] [ clear-set ] [ swap union! ] tri ;

: assoc-map! ( assoc quot -- assoc' )
    [ assoc-map ] [ drop clear-assoc ] [ drop swap assoc-union! ] 2tri ; inline

M: assoc (deref-aliases)
    [ [ (deref-aliases) ] bi-curry@ bi ] withd assoc-map! ;

: merge-values ( seq -- assoc )
    reverse [ ] [ assoc-union ] map-reduce ;
GENERIC: merge-value ( assoc value -- assoc' )
M: sequence merge-value merge-values merge-value ;
M: assoc merge-value over assoc-diff assoc-union! ;
: pop-at* ( key assoc -- value/f ? )
    [ at* ] 2keep pick [ delete-at ] [ 2drop ] if ;

: ?apply-default-key ( assoc -- obj' )
    T{ yaml-value } over pop-at* [ nip ] [ drop ] if ;
PRIVATE>

: ?apply-merge-key ( assoc -- assoc' )
    T{ yaml-merge } over pop-at*
    [ merge-value ] [ drop ] if ;
: scalar-value ( obj -- obj' )
    dup hashtable? [ ?apply-default-key ] when ;

<PRIVATE

GENERIC: apply-merge-keys ( already-applied-set obj -- obj' )
: ?apply-merge-keys ( set obj -- obj' )
    2dup swap ?adjoin [ apply-merge-keys ] [ nip ] if ;
M: sequence apply-merge-keys
    [ ?apply-merge-keys ] with map! ;
M: object apply-merge-keys nip ;
M: byte-array apply-merge-keys nip ;
M: string apply-merge-keys nip ;
M: assoc apply-merge-keys
    [ [ ?apply-merge-keys ] bi-curry@ bi ] withd assoc-map!
    merge get [ ?apply-merge-key ] when
    value get [ ?apply-default-key ] when ;

:: parse-yaml-doc ( parser event -- obj )
    H{ } clone anchors [
        parser event next-value
        anchors get swap (deref-aliases)
        merge get value get or [ IHS{ } clone swap ?apply-merge-keys ] when
    ] with-variable ;

:: ?parse-yaml-doc ( parser event -- obj/f ? )
    [
        parser event next-event type>> {
            { YAML_DOCUMENT_START_EVENT [ t ] }
            { YAML_STREAM_END_EVENT [ f ] }
            [ { YAML_DOCUMENT_START_EVENT YAML_STREAM_END_EVENT } yaml-unexpected-event ]
        } case
    ] with-destructors [
        parser event parse-yaml-doc t
        parser event YAML_DOCUMENT_END_EVENT expect-event
    ] [ f f ] if ;

! registers destructors (use with with-destructors)
:: init-parser ( str -- parser event )
    yaml_parser_t (malloc-struct) &free :> parser
    parser yaml_parser_initialize yaml-initialize-assert-ok
    parser &yaml_parser_delete drop

    str utf8 encode
    [ malloc-byte-array &free ] [ length ] bi :> ( input length )
    parser input length yaml_parser_set_input_string

    yaml_event_t (malloc-struct) &free :> event
    parser event ;

PRIVATE>

: yaml> ( str -- obj )
    [
        init-parser
        [ YAML_STREAM_START_EVENT expect-event ]
        [ ?parse-yaml-doc [ yaml-no-document ] unless ] 2bi
    ] with-destructors ;

: yaml-docs> ( str -- arr )
    [
        init-parser
        [ YAML_STREAM_START_EVENT expect-event ]
        [ [ ?parse-yaml-doc ] 2curry [ ] produce nip ] 2bi
    ] with-destructors ;

<PRIVATE

TUPLE: yaml-anchors objects new-objects next-anchor ;

: <yaml-anchors> ( -- yaml-anchors )
    IH{ } clone IH{ } clone 0 yaml-anchors boa ;

GENERIC: (replace-aliases) ( yaml-anchors obj -- obj' )

: incr-anchor ( yaml-anchors -- current-anchor )
    [ next-anchor>> ] [
        [ [ number>string ] [ 1 + ] bi ]
        [ next-anchor<< ] bi*
    ] bi ;

:: (?replace-aliases) ( yaml-anchors obj -- obj' )
    yaml-anchors objects>> :> objects
    obj objects at* [
        [ yaml-anchors incr-anchor dup obj objects set-at ] unless*
        <yaml-alias>
    ] [
        drop f obj objects set-at
        yaml-anchors obj (replace-aliases) :> obj'
        obj obj' yaml-anchors new-objects>> set-at
        obj'
    ] if ;

: ?replace-aliases ( yaml-anchors obj -- obj' )
    dup fixnum? [ nip ] [ (?replace-aliases) ] if ;

M: object (replace-aliases) nip ;

M: byte-array (replace-aliases) nip ;

M: string (replace-aliases) nip ;

M: sequence (replace-aliases)
    [ ?replace-aliases ] with map ;

M: sets:set (replace-aliases)
    [ members (replace-aliases) ] keep set-like ;

M: assoc (replace-aliases)
    swap '[ [ _ swap ?replace-aliases ] bi@ ] assoc-map ;

TUPLE: yaml-anchor anchor obj ;
C: <yaml-anchor> yaml-anchor

GENERIC: (replace-anchors) ( yaml-anchors obj -- obj' )

: (get-anchor) ( yaml-anchors obj -- anchor/f )
    swap objects>> at ;

: get-anchor ( yaml-anchors obj -- anchor/f )
    { [ (get-anchor) ] [ over new-objects>> at (get-anchor) ] } 2|| ;

: ?replace-anchors ( yaml-anchors obj -- obj' )
    [ (replace-anchors) ] [ get-anchor ] 2bi [ swap <yaml-anchor> ] when* ;

M: object (replace-anchors) nip ;

M: byte-array (replace-anchors) nip ;

M: string (replace-anchors) nip ;

M: sequence (replace-anchors)
    [ ?replace-anchors ] with map ;

M: sets:set (replace-anchors)
    [ members ?replace-anchors ] keep set-like ;

M: assoc (replace-anchors)
    swap '[ [ _ swap ?replace-anchors ] bi@ ] assoc-map ;

: replace-identities ( obj -- obj' )
    [ <yaml-anchors> ] dip dupd ?replace-aliases ?replace-anchors ;

! TODO We can also pass some data when registering the write handler,
! use this to have several buffers if it can be interrupted.
! For now, only do operations on strings that are in memory
! so we don't need to be reentrant.
SYMBOL: yaml-write-buffer
: yaml-write-handler ( -- alien )
    [
        memory>byte-array yaml-write-buffer get-global
        push-all drop 1
    ] yaml_write_handler_t ;

GENERIC: emit-value ( emitter event anchor obj -- )

: emit-object ( emitter event obj -- ) [ f ] dip emit-value ;

: scalar-implicit-tag? ( tag str mapping-key? -- plain_implicit quoted_implicit )
    implicit-tags get [
        resolve-plain-scalar = t
    ] [ 3drop f f ] if ;

:: (emit-scalar) ( emitter event anchor obj mapping-key? -- )
    event anchor
    obj [ yaml-tag ] [ represent-scalar ] bi
    -1 2over mapping-key? scalar-implicit-tag? YAML_ANY_SCALAR_STYLE
    yaml_scalar_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted ;

: emit-mapping-key-scalar ( emitter event anchor obj -- ) t (emit-scalar) ;
: emit-scalar ( emitter event anchor obj -- ) f (emit-scalar) ;

! strings and special keys are the only things that need special treatment
! because they can have the same representation
: emit-mapping-key ( emitter event obj -- )
    dup { [ string? ] [ yaml-merge? ] [ yaml-value? ] } 1||
    [ [ f ] dip emit-mapping-key-scalar ] [ emit-object ] if ;

M: object emit-value ( emitter event anchor obj -- ) emit-scalar ;

M: yaml-anchor emit-value ( emitter event unused obj -- )
    nip [ anchor>> ] [ obj>> ] bi emit-value ;

M:: yaml-alias emit-value ( emitter event unused obj -- )
    event obj anchor>> yaml_alias_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted ;

:: emit-sequence-start ( emitter event anchor tag implicit -- )
    event anchor tag implicit YAML_ANY_SEQUENCE_STYLE
    yaml_sequence_start_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted ;

: emit-sequence-end ( emitter event -- )
    dup yaml_sequence_end_event_initialize yaml-initialize-assert-ok
    yaml_emitter_emit_asserted ;

: emit-sequence-body ( emitter event seq -- )
    [ emit-object ] 2with each ;

: emit-assoc-body ( emitter event assoc -- )
    [
        [ emit-mapping-key ]
        [ emit-object ] bi-curry* 2bi
    ] withd withd assoc-each ;

: emit-linked-assoc-body ( emitter event linked-assoc -- )
    >alist [ first2 swap associate ] map emit-sequence-body ;

: emit-set-body ( emitter event set -- )
    [ members ] [ cardinality f <array> ] bi zip concat emit-sequence-body ;

M: f emit-value ( emitter event anchor f -- ) emit-scalar ;

M: string emit-value ( emitter event anchor string -- ) emit-scalar ;

M: byte-array emit-value ( emitter event anchor byte-array -- ) emit-scalar ;

M: sequence emit-value ( emitter event anchor seq -- )
    [ drop YAML_SEQ_TAG implicit-tags get emit-sequence-start ]
    [ nip emit-sequence-body ]
    [ 2drop emit-sequence-end ] 4tri ;

M: linked-assoc emit-value ( emitter event anchor assoc -- )
    [ drop YAML_OMAP_TAG f emit-sequence-start ]
    [ nip emit-linked-assoc-body ]
    [ 2drop emit-sequence-end ] 4tri ;

:: emit-assoc-start ( emitter event anchor tag implicit -- )
    event anchor tag implicit YAML_ANY_MAPPING_STYLE
    yaml_mapping_start_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted ;

: emit-assoc-end ( emitter event -- )
    dup yaml_mapping_end_event_initialize yaml-initialize-assert-ok
    yaml_emitter_emit_asserted ;

M: assoc emit-value ( emitter event anchor assoc -- )
    [ drop YAML_MAP_TAG implicit-tags get emit-assoc-start ]
    [ nip emit-assoc-body ]
    [ 2drop emit-assoc-end ] 4tri ;

M: sets:set emit-value ( emitter event anchor set -- )
    [ drop YAML_SET_TAG f emit-assoc-start ]
    [ nip emit-set-body ]
    [ 2drop emit-assoc-end ] 4tri ;

: unless-libyaml-default ( variable quot -- )
    [ get dup +libyaml-default+ = not ] dip
    [ 2drop ] if ; inline

: init-emitter-options ( emitter -- )
    {
        [ emitter-canonical [ yaml_emitter_set_canonical ] unless-libyaml-default ]
        [ emitter-indent [ yaml_emitter_set_indent ] unless-libyaml-default ]
        [ emitter-width [ yaml_emitter_set_width ] unless-libyaml-default ]
        [ emitter-unicode [ yaml_emitter_set_unicode ] unless-libyaml-default ]
        [ emitter-line-break [ yaml_emitter_set_break ] unless-libyaml-default ]
    } cleave ;

! registers destructors (use with with-destructors)
:: init-emitter ( -- emitter event )
    yaml_emitter_t (malloc-struct) &free :> emitter
    emitter yaml_emitter_initialize yaml-initialize-assert-ok
    emitter &yaml_emitter_delete drop
    emitter init-emitter-options

    BV{ } clone :> output
    output yaml-write-buffer set-global
    emitter yaml-write-handler f yaml_emitter_set_output

    yaml_event_t (malloc-struct) &free :> event

    event YAML_UTF8_ENCODING
    yaml_stream_start_event_initialize yaml-initialize-assert-ok

    emitter event yaml_emitter_emit_asserted
    emitter event ;

:: emit-doc ( emitter event obj -- )
    event f f f implicit-start get yaml_document_start_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted

    emitter event obj emit-object

    event implicit-end get yaml_document_end_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted ;

:: flush-emitter ( emitter event -- str )
    event yaml_stream_end_event_initialize yaml-initialize-assert-ok
    emitter event yaml_emitter_emit_asserted

    emitter [ yaml_emitter_flush ] [ yaml-emitter-assert-ok ] bi
    yaml-write-buffer get utf8 decode ;

PRIVATE>

: >yaml ( obj -- str )
    [
        [ init-emitter ] dip
        [ replace-identities emit-doc ] [ drop flush-emitter ] 3bi
    ] with-destructors ;

: >yaml-docs ( seq -- str )
    [
        [ init-emitter ] dip
        [ [ replace-identities emit-doc ] 2with each ] [ drop flush-emitter ] 3bi
    ] with-destructors ;
