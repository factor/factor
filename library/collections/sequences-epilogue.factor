! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: arrays errors generic kernel kernel-internals math
sequences-internals strings vectors words ;

: first2 ( seq -- first second )
    1 swap bounds-check nip first2-unsafe ;

: first3 ( seq -- first second third )
    2 swap bounds-check nip first3-unsafe ;

: first4 ( seq -- first second third fourth )
    3 swap bounds-check nip first4-unsafe ;

M: object like drop ;

: index ( obj seq -- n )
    [ = ] find-with drop ;

: index* ( obj i seq -- n )
    [ = ] find-with* drop ;

: last-index ( obj seq -- n )
    [ = ] find-last-with drop ;

: last-index* ( obj i seq -- n )
    [ = ] find-last-with* drop ;

: member? ( obj seq -- ? )
    [ = ] contains-with? ;

: memq? ( obj seq -- ? )
    [ eq? ] contains-with? ;

: remove ( obj list -- list )
    [ = not ] subset-with ;

: (subst) ( newseq oldseq elt -- new/elt )
    [ swap index ] keep
    over -1 > [ drop swap nth ] [ 2nip ] if ;

: subst ( newseq oldseq seq -- )
    [ >r 2dup r> (subst) ] inject 2drop ;

: move ( m n seq -- )
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

: prune ( seq -- newseq )
    [ V{ } clone swap [ over push-new ] each ] keep like ;

: nappend ( dest src -- )
    >r [ length ] keep r> copy-into ; inline

: >resizable ( seq -- newseq ) [ thaw dup ] keep nappend ;

: immutable ( seq quot -- newseq )
    swap [ >resizable [ swap call ] keep ] keep like ; inline

: append ( seq1 seq2 -- newseq )
    swap [ swap nappend ] immutable ;

: add ( seq elt -- newseq )
    swap [ push ] immutable ;

: add* ( seq elt -- newseq )
    over >r
    over thaw [ push ] keep [ swap nappend ] keep
    r> like ;

: diff ( seq1 seq2 -- newseq )
    [ swap member? not ] subset-with ;

: append3 ( seq1 seq2 seq3 -- newseq )
    rot [ [ rot nappend ] keep swap nappend ] immutable ;

: peek ( seq -- elt ) dup length 1- swap nth ;

: pop* ( seq -- ) dup length 1- swap set-length ;

: pop ( seq -- ) dup length 1- swap [ nth ] 2keep set-length ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: (mismatch) ( seq1 seq2 n -- i )
    [ >r 2dup r> 2nth-unsafe = not ] find drop 2nip ; inline

: mismatch ( seq1 seq2 -- i )
    2dup min-length (mismatch) ;

: flip ( matrix -- newmatrix )
    dup empty? [
        dup first [ length ] keep like
        [ swap [ nth ] map-with ] map-with
    ] unless ;

: unpair ( assoc -- keys values )
    flip dup empty? [ drop { } { } ] [ first2 ] if ;

: exchange ( m n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: assoc ( key assoc -- value ) 
    [ first = ] find-with nip second ;

: rassoc ( value assoc -- key ) 
    [ second = ] find-with nip first ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: sequence= ( seq1 seq2 -- ? )
    2dup [ length ] 2apply tuck number=
    [ (mismatch) -1 number= ] [ 3drop f ] if ; inline

M: array equal?
    over array? [ sequence= ] [ 2drop f ] if ;

M: quotation equal?
    over quotation? [ sequence= ] [ 2drop f ] if ;

M: sbuf equal?
    over sbuf? [ sequence= ] [ 2drop f ] if ;

M: vector equal?
    over vector? [ sequence= ] [ 2drop f ] if ;

UNION: sequence array string sbuf vector quotation ;

M: sequence hashcode
    dup empty? [ drop 0 ] [ first hashcode ] if ;

IN: kernel

M: object <=>
    2dup mismatch dup -1 =
    [ drop [ length ] 2apply - ] [ 2nth-unsafe <=> ] if ;

: depth ( -- n ) datastack length ;

TUPLE: no-cond ;
: no-cond ( -- * ) <no-cond> throw ;

: cond ( assoc -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

: unix? ( -- ? )
    os { "freebsd" "linux" "macosx" "solaris" } member? ;
