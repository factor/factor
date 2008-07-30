! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry assocs arrays byte-arrays strings accessors sequences
kernel slots classes.algebra classes.tuple classes.tuple.private
words math math.private combinators sequences.private namespaces
slots.private classes compiler.tree.propagation.info ;
IN: compiler.tree.propagation.slots

! Propagation of immutable slots and array lengths

! Revisit this code when delegation is removed and when complex
! numbers become tuples.

UNION: fixed-length-sequence array byte-array string ;

: sequence-constructor? ( word -- ? )
    { <array> <byte-array> <string> } memq? ;

: constructor-output-class ( word -- class )
    {
        { <array> array }
        { <byte-array> byte-array }
        { <string> string }
    } at ;

: propagate-sequence-constructor ( #call word -- infos )
    [ in-d>> first <sequence-info> ]
    [ constructor-output-class <class-info> ]
    bi* value-info-intersect 1array ;

: tuple-constructor? ( word -- ? )
    { <tuple-boa> <complex> } memq? ;

: read-only-slots ( values class -- slots )
    #! Delegation.
    all-slots rest-slice
    [ read-only>> [ drop f ] unless ] 2map
    { f f } prepend ;

: fold-<tuple-boa> ( values class -- info )
    [ , f , [ literal>> ] map % ] { } make >tuple
    <literal-info> ;

: propagate-<tuple-boa> ( #call -- info )
    #! Delegation
    in-d>> [ value-info ] map unclip-last
    literal>> class>> [ read-only-slots ] keep
    over 2 tail-slice [ dup [ literal?>> ] when ] all? [
        [ 2 tail-slice ] dip fold-<tuple-boa>
    ] [
        <tuple-info>
    ] if ;

: propagate-<complex> ( #call -- info )
    in-d>> [ value-info ] map complex <tuple-info> ;

: propagate-tuple-constructor ( #call word -- infos )
    {
        { \ <tuple-boa> [ propagate-<tuple-boa> ] }
        { \ <complex> [ propagate-<complex> ] }
    } case 1array ;

: read-only-slot? ( n class -- ? )
    all-slots [ offset>> = ] with find nip
    dup [ read-only>> ] when ;

: literal-info-slot ( slot object -- info/f )
    2dup class read-only-slot?
    [ swap slot <literal-info> ] [ 2drop f ] if ;

: length-accessor? ( slot info -- ? )
    [ 1 = ] [ length>> ] bi* and ;

: value-info-slot ( slot info -- info' )
    #! Delegation.
    {
        { [ over 0 = ] [ 2drop fixnum <class-info> ] }
        { [ 2dup length-accessor? ] [ nip length>> ] }
        { [ dup literal?>> ] [ literal>> literal-info-slot ] }
        [ [ 1- ] [ slots>> ] bi* ?nth ]
    } cond [ object-info ] unless* ;
