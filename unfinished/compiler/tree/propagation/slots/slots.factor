! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry assocs arrays byte-arrays strings accessors sequences
kernel slots classes.algebra classes.tuple classes.tuple.private
words math math.private combinators sequences.private namespaces
compiler.tree.propagation.info ;
IN: compiler.tree.propagation.slots

! Propagation of immutable slots and array lengths

! Revisit this code when delegation is removed and when complex
! numbers become tuples.

UNION: fixed-length-sequence array byte-array string ;

: sequence-constructor? ( node -- ? )
    word>> { <array> <byte-array> <string> } memq? ;

: constructor-output-class ( word -- class )
    {
        { <array> array }
        { <byte-array> byte-array }
        { <string> string }
    } at ;

: propagate-sequence-constructor ( node -- infos )
    [ word>> constructor-output-class <class-info> ]
    [ in-d>> first <sequence-info> ]
    bi value-info-intersect 1array ;

: length-accessor? ( node -- ? )
    dup in-d>> first fixed-length-sequence value-is?
    [ word>> \ length eq? ] [ drop f ] if ;

: propagate-length ( node -- infos )
    in-d>> first value-info length>>
    [ array-capacity <class-info> ] unless* 1array ;

: tuple-constructor? ( node -- ? )
    word>> { <tuple-boa> <complex> } memq? ;

: propagate-<tuple-boa> ( node -- info )
    #! Delegation
    in-d>> [ value-info ] map unclip-last
    literal>> class>> dup immutable-tuple-class? [
        over [ literal?>> ] all?
        [ [ , f , [ literal>> ] map % ] { } make >tuple <literal-info> ]
        [ <tuple-info> ]
        if
    ] [ nip <class-info> ] if ;

: propagate-<complex> ( node -- info )
    in-d>> [ value-info ] map complex <tuple-info> ;

: propagate-tuple-constructor ( node -- infos )
    dup word>> {
        { \ <tuple-boa> [ propagate-<tuple-boa> ] }
        { \ <complex> [ propagate-<complex> ] }
    } case 1array ;

: relevant-methods ( node -- methods )
    [ word>> "methods" word-prop ]
    [ in-d>> first value-info class>> ] bi
    '[ drop , classes-intersect? ] assoc-filter ;

: relevant-slots ( node -- slots )
    relevant-methods [ nip "reading" word-prop ] { } assoc>map ;

: no-reader-methods ( input slots -- info )
    2drop null <class-info> ;

: same-offset ( slots -- slot/f )
    dup [ dup [ read-only>> ] when ] all? [
        [ offset>> ] map dup all-equal? [ first ] [ drop f ] if
    ] [ drop f ] if ;

: (reader-word-outputs) ( reader -- info )
    null
    [ [ class>> ] [ object ] if* class-or ] reduce
    <class-info> ;

: value-info-slot ( slot info -- info' )
    #! Delegation.
    [ class>> complex class<= 1 3 ? - ] keep
    dup literal?>> [
        literal>> {
            { [ dup tuple? ] [
                tuple-slots 1 tail-slice nth <literal-info>
            ] }
            { [ dup complex? ] [
                [ real-part ] [ imaginary-part ] bi
                2array nth <literal-info>
            ] }
        } cond
    ] [ slots>> ?nth ] if ;

: reader-word-outputs ( node -- infos )
    [ relevant-slots ] [ in-d>> first ] bi
    over empty? [ no-reader-methods ] [
        over same-offset dup
        [ swap value-info value-info-slot ] [ 2drop f ] if
        [ ] [ (reader-word-outputs) ] ?if
    ] if 1array ;

: reader-word-inputs ( node -- )
    [ in-d>> first ] [
        relevant-slots keys
        object [ class>> [ class-and ] when* ] reduce
        <class-info>
    ] bi
    refine-value-info ;
