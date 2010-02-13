! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry assocs arrays byte-arrays strings accessors sequences
kernel slots classes.algebra classes.tuple classes.tuple.private
combinators.short-circuit words math math.private combinators
sequences.private namespaces slots.private classes
compiler.tree.propagation.info ;
IN: compiler.tree.propagation.slots

! Propagation of immutable slots and array lengths

UNION: fixed-length-sequence array byte-array string ;

: sequence-constructor? ( word -- ? )
    { <array> <byte-array> (byte-array) <string> } member-eq? ;

: constructor-output-class ( word -- class )
    {
        { <array> array }
        { <byte-array> byte-array }
        { (byte-array) byte-array }
        { <string> string }
    } at ;

: propagate-sequence-constructor ( #call word -- infos )
    [ in-d>> first <sequence-info> ]
    [ constructor-output-class <class-info> ]
    bi* value-info-intersect 1array ;

: fold-<tuple-boa> ( values class -- info )
    [ [ literal>> ] map ] dip prefix >tuple
    <literal-info> ;

: read-only-slots ( values class -- slots )
    all-slots
    [ read-only>> [ value-info ] [ drop f ] if ] 2map
    f prefix ;

: (propagate-tuple-constructor) ( values class -- info )
    [ read-only-slots ] keep
    over rest-slice [ dup [ literal?>> ] when ] all? [
        [ rest-slice ] dip fold-<tuple-boa>
    ] [
        <tuple-info>
    ] if ;

: propagate-<tuple-boa> ( #call -- infos )
    in-d>> unclip-last
    value-info literal>> first (propagate-tuple-constructor) 1array ;

: read-only-slot? ( n class -- ? )
    all-slots [ offset>> = ] with find nip
    dup [ read-only>> ] when ;

: literal-info-slot ( slot object -- info/f )
    #! literal-info-slot makes an unsafe call to 'slot'.
    #! Check that the layout is up to date to avoid accessing the
    #! wrong slot during a compilation unit where reshaping took
    #! place. This could happen otherwise because the "slots" word
    #! property would reflect the new layout, but instances in the
    #! heap would use the old layout since instances are updated
    #! immediately after compilation.
    {
        [ class read-only-slot? ]
        [ nip layout-up-to-date? ]
        [ swap slot <literal-info> ]
    } 2&& ;

: length-accessor? ( slot info -- ? )
    [ 1 = ] [ length>> ] bi* and ;

: value-info-slot ( slot info -- info' )
    {
        { [ over 0 = ] [ 2drop fixnum <class-info> ] }
        { [ 2dup length-accessor? ] [ nip length>> ] }
        { [ dup literal?>> ] [ literal>> literal-info-slot ] }
        [ [ 1 - ] [ slots>> ] bi* ?nth ]
    } cond [ object-info ] unless* ;
