! Copyright (C) 2025 Leo Mehraban
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs classes classes.parser
classes.private combinators compiler.units kernel lexer make
math parser prettyprint.backend prettyprint.custom
prettyprint.sections see see.private sequences splitting
vocabs.prettyprint words words.constant ;

IN: classes.enumeration

PREDICATE: enumeration-class < class
    "metaclass" word-prop enumeration-class eq? ;

PREDICATE: enumeration-member-word < word "enum-elt-value" word-prop [ t ] [ f ] if ;

ERROR: incorrect-type-in-enum-value expected-type value word ;

<PRIVATE

: verify-types ( superclass member-assoc -- ) 
    [ drop dup "enum-elt-value" word-prop ] assoc-map
    [ pick instance? not nip ] assoc-find [ swap incorrect-type-in-enum-value ] [ 3drop ] if* ;

: (define-enum-class) ( class superclass member-assoc -- )
    dup -rotd [ values index >boolean ] curry {
        [ drop pick verify-types drop ]
        [ drop f f enumeration-class define-class ]
        [ nip "predicate-definition" set-word-prop ]
        [ 2drop swap "enum-member-assoc" set-word-prop ]
        [ nip [ define-predicate ] keepd update-classes ]
    } 3cleave ;

! enum-value-overwritten has two reasons to exist:
!   it's the only way to check if an expected value has been manually overwritten
!   it provides the counter-quot if that is overwritten
! both of these are only used for `see`, which seems a bit of a
! waste, but I can't think of another way and besides, it's not
! like adding another word prop really does anything
: define-enum-elt-word ( class name counter overwrite? -- counter )
    [
        [
            [
                [ CHAR: . prefix [ dup name>> ] dip append create-word-in ] dip
                [ define-constant ] keepd swap [ "parent-enum" set-word-prop ] keepd
            ] keep [ [ swap ,, ] [ [ "enum-elt-value" set-word-prop ] keepd [ f "parsing-word" set-word-prop ] keep ] 2bi ] keep
        ] dip swap [ "enum-value-overwritten" set-word-prop ] dip 
    ] with-nested-compilation-unit ;

: parse-enum-elt ( class name counter counter-quot -- counter counter-quot )
    pick {
        {
            "{"
            [
                nipd scan-word-name -rot
                \ } parse-until 2 index-or-length head
                {
                    { [ dup length 0 = ] [ drop f swap ] }
                    { [ dup length 1 = ] [ nipd first t rot ] }
                    [ 2nip first2 dup ]
                } cond
                [ define-enum-elt-word ] dip
            ]
        }
        [ drop [ f define-enum-elt-word ] dip ]
    } case
    [ call( current -- next ) ] keep ;

: parse-enum-elts ( class starting-counter counter-quot -- )
    [
        [ scan-word-name dup ";" = not ] 2dip
        rot
        [ [ dup ] 3dip parse-enum-elt t ]
        [ nipd f ] if
    ] loop 3drop ;

: parse-enum ( class -- )
    [
        scan-word-name
        {
            { ";" [ f ";" unexpected ] }
            { "<" [ scan-word [ dup 0 [ 1 + ] parse-enum-elts ] dip ] }
            [ [ dup dup ] dip 0 [ 1 + ] parse-enum-elt parse-enum-elts fixnum ]
        } case
    ] { } make (define-enum-class) ;

: enum-elt-root-name ( enum-elt -- root-name )
    dup "parent-enum" word-prop [ name>> ] bi@ ?head t assert= rest ;

: create-enum-member-assoc ( class member-list -- member-assoc )
    [ 0 [ 1 + ] ] 2dip [
        [
            unclip swap [ rot rotd ] dip {
                { [ dup length 0 = ] [ drop f swap ] }
                { [ dup length 1 = ] [ nipd first t rot ] }
                [ 2nip first2 dup ]
            } cond
            [ define-enum-elt-word ] dip
            [ call( current -- next ) ] keep
        ] with each 2drop
    ] { } make ;

PRIVATE>

: define-enum-class ( class superclass member-list -- )
    overd create-enum-member-assoc (define-enum-class) ;

: enum-member-list ( enumeration-class -- member-list )
    "enum-member-assoc" word-prop [
        over "enum-value-overwritten" word-prop [
            dup t = [
                drop [ enum-elt-root-name ] dip 2array
            ] [
                [ enum-elt-root-name ] 2dip 3array
            ] if
        ] [ drop enum-elt-root-name 1array ] if*
     ] { } assoc>map ;

SYNTAX: ENUMERATION: scan-new-class parse-enum ;

<PRIVATE

TUPLE: string-wrapper str ;
M: string-wrapper pprint* str>> text ;

M: enumeration-class see-class*
    <colon \ ENUMERATION: pprint-word {
        [ pprint-word ]
        [ superclass-of dup fixnum eq? [ drop ] [ "<" text pprint-word ] if ]
        [
            <block
                enum-member-list [
                    dup length 1 = [ first text ] [ unclip string-wrapper boa prefix pprint-object ] if
                ] each
            block> pprint-;
        ]
    } cleave block> ;

PRIVATE>
