! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences-internals
USING: errors generic kernel kernel-internals lists math
sequences strings vectors words ;

: (lexi) ( seq seq i limit -- n )
    2dup >= [
        2drop [ length ] 2apply -
    ] [
        >r 3dup 2nth-unsafe 2dup = [
            2drop 1+ r> (lexi)
        ] [
            r> drop - >r 3drop r>
        ] if
    ] if ; flushable

IN: sequences

: first2 ( { x y } -- x y )
    1 swap bounds-check nip first2-unsafe ; inline

: first3 ( { x y z } -- x y z )
    2 swap bounds-check nip first3-unsafe ; inline

: first4 ( { x y z w } -- x y z w )
    3 swap bounds-check nip first4-unsafe ; inline

M: object like drop ;

M: object empty? ( seq -- ? ) length 0 = ;

: (>list) ( n i seq -- list )
    pick pick <= [
        3drop [ ]
    ] [
        2dup nth >r >r 1+ r> (>list) r> swons
    ] if ;

M: object >list ( seq -- list ) dup length 0 rot (>list) ;

: index   ( obj seq -- n )     [ = ] find-with drop ; flushable
: index*  ( obj i seq -- n )   [ = ] find-with* drop ; flushable
: member? ( obj seq -- ? )     [ = ] contains-with? ; flushable
: memq?   ( obj seq -- ? )     [ eq? ] contains-with? ; flushable
: remove  ( obj list -- list ) [ = not ] subset-with ; flushable

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

: copy-into-check ( start to from -- )
    rot rot length + swap length < [
        "Cannot copy beyond end of sequence" throw
    ] when ;

: copy-into ( start to from -- )
    3dup copy-into-check dup length
    [ >r pick r> + pick set-nth-unsafe ] 2each 2drop ;
    inline

: nappend ( to from -- )
    >r dup length swap r>
    over length over length + pick set-length
    copy-into ; inline

: append ( s1 s2 -- s1+s2 )
    swap [ swap nappend ] immutable ; flushable

: add ( seq elt -- seq )
    swap [ push ] immutable ; flushable

: adjoin ( elt seq -- )
    2dup member? [ 2drop ] [ push ] if ;

: prune ( seq -- seq )
    dup dup length <vector> swap [ over adjoin ] each swap like ;

: diff ( seq1 seq2 -- seq2-seq1 )
    [ swap member? not ] subset-with ; flushable

: append3 ( s1 s2 s3 -- s1+s2+s3 )
    rot [ [ rot nappend ] keep swap nappend ] immutable ; flushable

: concat ( seq -- seq )
    dup empty? [
        [ 1024 <vector> swap [ dupd nappend ] each ] keep
        first like
    ] unless ; flushable

M: object peek ( sequence -- element )
    dup length 1- swap nth ;

: pop* ( sequence -- )
    [ length 1- ] keep
    [ 0 -rot set-nth ] 2keep
    set-length ; inline

: pop ( sequence -- element )
    dup peek swap pop* ; inline

: join ( seq glue -- seq )
    swap dup empty? [
        swap like
    ] [
        dup length <vector> swap
        [ over push 2dup push ] each nip dup pop*
        concat
    ] if ; flushable

M: object reverse-slice ( seq -- seq ) <reversed> ;

M: object reverse ( seq -- seq ) [ <reversed> ] keep like ;

: all-equal? ( seq -- ? ) [ = ] monotonic? ;

: all-eq? ( seq -- ? ) [ eq? ] monotonic? ;

: mismatch ( seq1 seq2 -- i )
    2dup min-length
    [ >r 2dup r> 2nth-unsafe = not ] find
    swap >r 3drop r> ; flushable

: lexi ( s1 s2 -- n )
    2dup mismatch dup -1 =
    [ drop [ length ] 2apply - ] [ 2nth-unsafe - ] if ;
    flushable

: flip ( seq -- seq )
    dup empty? [
        dup first [ length ] keep like
        [ swap [ nth ] map-with ] map-with
    ] unless ; flushable

IN: kernel

: depth ( -- n )
    #! Push the number of elements on the datastack.
    datastack length ;

: no-cond "cond fall-through" throw ;

: cond ( conditions -- )
    #! Conditions is a sequence of quotation pairs.
    #! { { [ X ] [ Y ] } { [ Z ] [ T ] } }
    #! => X [ Y ] [ Z [ T ] [ ] if ] if
    #! The last condition should be a catch-all 't'.
    [ first call ] find nip dup
    [ second call ] [ no-cond ] if ;

: with-datastack ( stack word -- stack )
    datastack >r >r set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;

: win32? ( -- ? ) os "win32" = ;

: unix? ( -- ? ) os { "freebsd" "linux" "macosx" } member? ;
