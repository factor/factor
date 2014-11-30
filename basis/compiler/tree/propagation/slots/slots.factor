! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: fry assocs arrays byte-arrays strings accessors sequences
kernel slots classes.algebra classes.tuple classes.tuple.private
combinators.short-circuit words math math.private combinators
sequences.private namespaces slots.private classes
compiler.tree.propagation.info ;
IN: compiler.tree.propagation.slots

! Propagation of immutable slots and array lengths

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
    [ in-d>> first value-info ]
    [ constructor-output-class ] bi*
    <sequence-info> 1array ;

: fold-<tuple-boa> ( values class -- info )
    [ [ literal>> ] map ] dip slots>tuple
    <literal-info> ;

: read-only-slots ( values class -- slots )
    all-slots
    [ read-only>> [ value-info ] [ drop f ] if ] 2map
    f prefix ;

: fold-<tuple-boa>? ( values class -- ? )
    [ rest-slice [ dup [ literal?>> ] when ] all? ]
    [ identity-tuple class<= not ]
    bi* and ;

: (propagate-<tuple-boa>) ( values class -- info )
    [ read-only-slots ] keep 2dup fold-<tuple-boa>?
    [ [ rest-slice ] dip fold-<tuple-boa> ] [ <tuple-info> ] if ;

: propagate-<tuple-boa> ( #call -- infos )
    in-d>> unclip-last
    value-info literal>> first (propagate-<tuple-boa>) 1array ;

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
        [ class-of read-only-slot? ]
        [ nip layout-up-to-date? ]
        [ swap slot <literal-info> ]
    } 2&& ;

: length-accessor? ( slot info -- ? )
    [ 1 = ] [ length>> ] bi* and ;

: value-info-slot ( slot info -- info' )
    {
        { [ over 0 = ] [ 2drop fixnum <class-info> ] }
        { [ dup literal?>> ] [ literal>> literal-info-slot ] }
        [ [ 1 - ] [ slots>> ] bi* ?nth ]
    } cond [ object-info ] unless* ;
