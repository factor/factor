! Copyright (C) 2009, 2011 Joe Groff, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.prettyprint arrays assocs classes
classes.struct combinators combinators.short-circuit
continuations kernel libc make math math.parser mirrors
prettyprint.backend prettyprint.custom prettyprint.sections
see.private sequences slots summary vocabs.prettyprint ;
IN: classes.struct.prettyprint

<PRIVATE

: struct-definer-word ( class -- word )
    struct-slots
    {
        { [ dup [ packed?>> ] all? ] [ drop \ PACKED-STRUCT: ] }
        { [ dup length 1 <= ] [ drop \ STRUCT: ] }
        { [ dup [ offset>> 0 = ] all? ] [ drop \ UNION-STRUCT: ] }
        [ drop \ STRUCT: ]
    } cond ;

: struct>assoc ( struct -- assoc )
    [ class-of struct-slots ] [ struct-slot-values ] bi zip ;

: pprint-struct-slot ( slot -- )
    <flow \ { pprint-word
    f <inset {
        [ name>> text ]
        [ type>> pprint-c-type ]
        [ read-only>> [ \ read-only pprint-word ] when ]
        [ initial>> [ \ initial: pprint-word pprint* ] when* ]
        [
            dup struct-bit-slot-spec?
            [ \ bits: pprint-word bits>> pprint* ]
            [ drop ] if
        ]
    } cleave block>
    \ } pprint-word block> ;

: pprint-struct ( struct -- )
    [
        [ \ S{ ] dip
        [ class-of ]
        [ struct>assoc [ [ name>> ] dip ] assoc-map ] bi
        \ } (pprint-tuple)
    ] ?pprint-tuple ;

: pprint-struct-pointer ( struct -- )
    \ S@ [ [ class-of pprint-word ] [ >c-ptr pprint* ] bi ] pprint-prefix ;

PRIVATE>

M: struct-class see-class*
    <colon dup struct-definer-word pprint-word dup pprint-word
    <block struct-slots [ pprint-struct-slot ] each
    block> pprint-; block> ;

M: struct pprint-delims
    drop \ S{ \ } ;

M: struct >pprint-sequence
    [ class-of ] [ struct-slot-values ] bi class-slot-sequence ;

M: struct pprint*
    [ pprint-struct ]
    [ pprint-struct-pointer ] pprint-c-object ;

M: struct summary
    [
        dup class-of name>> %
        " struct of " %
        byte-length #
        " bytes " %
    ] "" make ;

TUPLE: struct-mirror { object read-only } ;
C: <struct-mirror> struct-mirror

: get-struct-slot ( struct slot -- value present? )
    over class-of struct-slots slot-named
    [ name>> reader-word execute( struct -- value ) t ]
    [ drop f f ] if* ;
: set-struct-slot ( value struct slot -- )
    over class-of struct-slots slot-named
    [ name>> writer-word execute( value struct -- ) ]
    [ 2drop ] if* ;
: reset-struct-slot ( struct slot -- )
    over class-of struct-slots slot-named
    [ [ initial>> swap ] [ name>> writer-word ] bi execute( value struct -- ) ]
    [ drop ] if* ;
: reset-struct-slots ( struct -- )
    dup class-of struct-prototype
    dup byte-length memcpy ;

M: struct-mirror at*
    object>> {
        { [ over "underlying" = ] [ nip >c-ptr t ] }
        { [ over { [ array? ] [ length 1 >= ] } 1&& ] [ swap first get-struct-slot ] }
        [ 2drop f f ]
    } cond ;

M: struct-mirror set-at
    object>> {
        { [ over "underlying" = ] [ 3drop ] }
        { [ over array? ] [ swap first set-struct-slot ] }
        [ 3drop ]
    } cond ;

M: struct-mirror delete-at
    object>> {
        { [ over "underlying" = ] [ 2drop ] }
        { [ over array? ] [ swap first reset-struct-slot ] }
        [ 2drop ]
    } cond ;

M: struct-mirror clear-assoc
    object>> reset-struct-slots ;

M: struct-mirror >alist
    object>> [
        [ drop "underlying" ] [ >c-ptr ] bi 2array 1array
    ] [
        '[
            _ struct>assoc
            [ [ [ name>> ] [ type>> ] bi 2array ] dip ] assoc-map
        ] [ drop { } ] recover
    ] bi append ;

M: struct make-mirror <struct-mirror> ;

INSTANCE: struct-mirror assoc
