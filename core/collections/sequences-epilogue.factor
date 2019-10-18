! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: arrays bit-arrays errors generic kernel kernel-internals
math sequences-internals strings sbufs vectors words ;

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

: add ( seq elt -- newseq ) 1array append ; inline

: add* ( seq elt -- newseq ) 1array swap dup (append) ; inline

: diff ( seq1 seq2 -- newseq )
    [ swap member? not ] subset-with ;

: peek ( seq -- elt ) dup length 1- swap nth ;

: pop* ( seq -- ) dup length 1- swap set-length ;

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

: nreverse ( seq -- )
    dup length dup 2 /i [
        >r 2dup r>
        tuck - 1- rot exchange-unsafe
    ] each 2drop ;

: concat ( seq -- newseq )
    dup empty? [
        [ 0 [ length + ] reduce ] keep
        [ first new-resizable ] keep
        [ [ over nappend ] each ] keep
        first like
    ] unless ;

: assoc* ( key assoc quot -- value )
    find-with swap 0 >= [ second ] when ; inline

: assoc ( key assoc -- value ) 
    [ first = ] assoc* ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: padding ( seq n elt -- newseq )
    >r swap length [-] r> <array> ;

: pad-left ( seq n elt -- padded )
    pick >r padding r> dup (append) ;

: pad-right ( seq n elt -- padded )
    pick >r padding r> swap append ;

UNION: sequence array bit-array string sbuf vector quotation ;

M: sequence hashcode
    dup empty? [ drop 0 ] [ first hashcode ] if ;

: group ( seq n -- array ) <groups> >array ;

IN: kernel

M: object <=>
    2dup mismatch dup -1 =
    [ drop [ length ] 2apply - ] [ 2nth-unsafe <=> ] if ;

: depth ( -- n ) datastack length ;

TUPLE: no-cond ;

: no-cond ( -- * ) <no-cond> throw ;

: cond ( assoc -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

TUPLE: no-case ;

: no-case ( -- * ) <no-case> throw ;

: case ( obj assoc -- ) assoc dup [ no-case ] if ;

: unix? ( -- ? )
    os {
        "freebsd" "openbsd" "linux" "macosx" "solaris"
    } member? ;

: with-datastack ( stack word -- newstack )
    datastack >r >r >vector set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;
