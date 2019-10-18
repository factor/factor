! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: arrays bit-arrays byte-arrays errors generic kernel
kernel-internals math sequences-internals strings sbufs vectors
words quotations ;

: (subst) ( newseq oldseq elt -- new/elt )
    [ swap index ] keep
    over [ drop swap nth ] [ 2nip ] if ;

: subst ( newseq oldseq seq -- )
    [ >r 2dup r> (subst) ] change-each 2drop ;

: move ( to from seq -- )
    pick pick number=
    [ 3drop ] [ [ nth swap ] keep set-nth ] if ; inline

: (delete) ( elt store scan seq -- elt store scan seq )
    2dup length < [
        3dup move
        [ nth pick = ] 2keep rot
        [ >r >r 1+ r> r> ] unless >r 1+ r> (delete)
    ] when ;

: delete ( elt seq -- ) 0 0 rot (delete) nip set-length drop ;

: push-new ( elt seq -- ) [ delete ] 2keep push ;

: add ( seq elt -- newseq ) 1array append ; inline

: add* ( seq elt -- newseq ) 1array swap dup (append) ; inline

: diff ( seq1 seq2 -- newseq )
    [ swap member? not ] subset-with ;

: peek ( seq -- elt ) dup length 1- swap nth ;

: pop* ( seq -- ) dup length 1- swap set-length ;

: move-backward ( shift from to seq -- )
    pick pick number= [
        2drop 2drop
    ] [
        [ >r pick pick + pick r> move >r 1+ r> ] keep
        move-backward
    ] if ;

: move-forward ( shift from to seq -- )
    pick pick number= [
        2drop 2drop
    ] [
        [ >r pick >r dup dup r> + swap r> move 1- ] keep
        move-forward
    ] if ;

: (open-slice) ( shift from to seq ? -- )
    [
        >r >r 1- r> 1- r> move-forward
    ] [
        >r >r over - r> r> move-backward
    ] if ;

: open-slice ( shift from seq -- )
    pick zero? [
        3drop
    ] [
        pick over length + over >r >r
        pick 0 > >r [ length ] keep r> (open-slice)
        r> r> set-length
    ] if ;

: delete-slice ( from to seq -- )
    3dup check-slice >r over >r - r> r> open-slice ;

: delete-nth ( n seq -- )
    >r dup 1+ r> delete-slice ;

: replace-slice ( new from to seq -- )
    [ >r >r dup pick length + r> - over r> open-slice ] keep
    copy ;

: pop ( seq -- elt )
    dup length 1- swap [ nth ] 2keep set-length ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: flip ( matrix -- newmatrix )
    dup empty? [
        dup first [ length [ <column> dup like ] map-with ] keep
        like
    ] unless ;

: unpair ( assoc -- keys values )
    flip dup empty? [ drop { } { } ] [ first2 ] if ;

: exchange ( m n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: reverse-here ( seq -- )
    dup length dup 2/ [
        >r 2dup r>
        tuck - 1- rot exchange-unsafe
    ] each 2drop ;

: concat ( seq -- newseq )
    dup empty? [
        drop { }
    ] [
        [ 0 [ length + ] reduce ] keep
        [ first new-resizable ] keep
        [ [ over push-all ] each ] keep
        first like
    ] if ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: padding ( seq n elt quot -- newseq )
    >r >r over length [-] dup zero?
    [ r> r> 3drop ] [ r> <array> r> call ] if ; inline

: pad-left ( seq n elt -- padded )
    [ swap dup (append) ] padding ;

: pad-right ( seq n elt -- padded )
    [ append ] padding ;

UNION: sequence array bit-array byte-array string sbuf vector
quotation ;

: group ( seq n -- array ) <groups> >array ;

IN: kernel

M: object <=>
    2dup mismatch
    [ 2nth-unsafe <=> ] [ [ length ] 2apply - ] if* ;

: depth ( -- n ) datastack length ;

TUPLE: no-cond ;

: no-cond ( -- * ) <no-cond> throw ;

: cond ( assoc -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

TUPLE: no-case ;

: no-case ( -- * ) <no-case> throw ;

: case ( obj assoc -- )
    [ dup array? [ dupd first = ] [ quotation? ] if ] find nip
    {
        { [ dup array? ] [ nip second call ] }
        { [ dup quotation? ] [ call ] }
        { [ dup not ] [ no-case ] }
    } cond ;

: unix? ( -- ? )
    os {
        "freebsd" "openbsd" "linux" "macosx" "solaris"
    } member? ;

: with-datastack ( stack quot -- newstack )
    datastack >r >r >vector set-datastack r> call
    datastack r> [ push ] keep set-datastack 2nip ; inline

: recursive-hashcode ( n obj quot -- code )
    pick 0 <= [ 3drop 0 ] [ rot 1- -rot call ] if ; inline

M: sequence hashcode*
    [
        0 -rot [ hashcode* bitxor ] each-with
    ] recursive-hashcode ;
