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

: remove ( obj seq -- newseq )
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

: ((append)) ( seq1 seq2 accum -- accum )
    [ >r over length r> rot copy-into ] keep
    [ 0 swap rot copy-into ] keep ; inline

: (3append) ( seq1 seq2 seq3 exemplar -- newseq )
    [
        >r pick length pick length pick length + + r> new
        [ >r pick length pick length + r> rot copy-into ] keep
        ((append))
    ] keep like ;

: 3append ( seq1 seq2 seq3 -- newseq )
    pick (3append) ; inline

: (append) ( seq1 seq2 exemplar -- newseq )
    [
        >r over length over length + r> new ((append))
    ] keep like ;

: append ( seq1 seq2 -- newseq )
    over (append) ; inline

: add ( seq elt -- newseq ) 1array append ; inline

: add* ( seq elt -- newseq ) 1array swap dup (append) ; inline

: concat ( seq -- newseq )
    dup empty? [
        [ 0 [ length + ] accumulate ] keep
        rot over first new -rot
        [ >r over r> copy-into ] 2each
    ] unless ;

: diff ( seq1 seq2 -- newseq )
    [ swap member? not ] subset-with ;

: peek ( seq -- elt ) dup length 1- swap nth ;

: pop* ( seq -- ) dup length 1- swap set-length ;

: pop ( seq -- elt )
    dup length 1- swap [ nth ] 2keep set-length ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: (mismatch) ( seq1 seq2 n -- i )
    [ >r 2dup r> 2nth-unsafe = not ] find drop 2nip ; inline

: mismatch ( seq1 seq2 -- i )
    2dup min-length (mismatch) ;

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

: assoc ( key assoc -- value ) 
    [ first = ] find-with nip second ;

: rassoc ( value assoc -- key ) 
    [ second = ] find-with nip first ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: padding ( seq n elt -- newseq )
    >r swap length [-] r> <array> ;

: pad-left ( seq n elt -- padded )
    pick >r pick >r padding r> append r> like ;

: pad-right ( seq n elt -- padded )
    pick >r padding r> swap append ;

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
