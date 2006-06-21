! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: sequences
USING: arrays errors generic kernel kernel-internals math
sequences-internals strings vectors words ;

: first2 ( { x y } -- x y )
    1 swap bounds-check nip first2-unsafe ;

: first3 ( { x y z } -- x y z )
    2 swap bounds-check nip first3-unsafe ;

: first4 ( { x y z w } -- x y z w )
    3 swap bounds-check nip first4-unsafe ;

M: object like drop ;

: index   ( obj seq -- n )
    [ = ] find-with drop ;

: index*  ( obj i seq -- n )
    [ = ] find-with* drop ;

: last-index   ( obj seq -- n )
    [ = ] find-last-with drop ;

: last-index*  ( obj i seq -- n )
    [ = ] find-last-with* drop ;

: member? ( obj seq -- ? )
    [ = ] contains-with? ;

: memq?   ( obj seq -- ? )
    [ eq? ] contains-with? ;

: remove  ( obj list -- list )
    [ = not ] subset-with ;

: (subst) ( newseq oldseq elt -- new/elt )
    [ swap index ] keep
    over -1 > [ drop swap nth ] [ 2nip ] if ;

: subst ( newseq oldseq seq -- )
    [ >r 2dup r> (subst) ] inject 2drop ;

: move ( to from seq -- )
    pick pick number=
    [ 3drop ] [ [ nth swap ] keep set-nth ] if ; inline

: (delete) ( elt store scan seq -- )
    2dup length < [
        3dup move
        >r pick over r> dup >r nth = r> swap
        [ >r >r 1+ r> r> ] unless >r 1+ r> (delete)
    ] when ;

: delete ( elt seq -- ) 0 0 rot (delete) nip set-length drop ;

: push-new ( elt seq -- ) [ delete ] 2keep push ;

: prune ( seq -- seq )
    [ V{ } clone swap [ over push-new ] each ] keep like ;

: nappend ( to from -- )
    >r [ length ] keep r> copy-into ; inline

: >resizable ( seq -- seq ) [ thaw dup ] keep nappend ;

: immutable ( seq quot -- seq | quot: seq -- )
    swap [ >resizable [ swap call ] keep ] keep like ; inline

: append ( s1 s2 -- s1+s2 )
    swap [ swap nappend ] immutable ;

: add ( seq elt -- seq )
    swap [ push ] immutable ;

: add* ( seq elt -- seq )
    over >r
    over thaw [ push ] keep [ swap nappend ] keep
    r> like ;

: diff ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ;

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    rot [ [ rot nappend ] keep swap nappend ] immutable ;

: peek ( sequence -- element ) dup length 1- swap nth ;

: pop* ( sequence -- )
    [ length 1- ] keep
    [ 0 -rot set-nth ] 2keep
    set-length ;

: pop ( sequence -- element )
    dup peek swap pop* ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: mismatch ( seq1 seq2 -- i )
    2dup min-length
    [ >r 2dup r> 2nth-unsafe = not ] find
    swap >r 3drop r> ;

: flip ( seq -- seq )
    dup empty? [
        dup first [ length ] keep like
        [ swap [ nth ] map-with ] map-with
    ] unless ;

: unpair ( seq -- firsts seconds )
    flip dup empty? [ drop { } { } ] [ first2 ] if ;

: exchange ( n n seq -- )
    pick over bounds-check 2drop 2dup bounds-check 2drop
    exchange-unsafe ;

: assoc ( key assoc -- value ) 
    [ first = ] find-with nip second ;

: rassoc ( value assoc -- key ) 
    [ second = ] find-with nip first ;

: last/first ( seq -- pair ) dup peek swap first 2array ;

: sequence= ( seq seq -- ? )
    2dup [ length ] 2apply = [
        dup length [ >r 2dup r> 2nth-unsafe = ] all? 2nip
    ] [
        2drop f
    ] if ;

UNION: sequence array string sbuf vector quotation ;

M: sequence = ( obj seq -- ? )
    2dup eq? [
        2drop t
    ] [
        over type over type eq? [ sequence= ] [ 2drop f ] if
    ] if ;

M: sequence hashcode ( seq -- n )
    #! Poor
    length ;

IN: kernel

M: object <=>
    2dup mismatch dup -1 =
    [ drop [ length ] 2apply - ] [ 2nth-unsafe <=> ] if ;

: depth ( -- n ) datastack length ;

: no-cond "cond fall-through" throw ;

: cond ( conditions -- )
    [ first call ] find nip dup [ second call ] [ no-cond ] if ;

: unix? os { "freebsd" "linux" "macosx" "solaris" } member? ;
