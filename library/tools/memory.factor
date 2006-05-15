! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: memory
USING: arrays errors generic hashtables io kernel
kernel-internals math namespaces parser prettyprint
sequences strings vectors words ;

: full-gc ( -- ) generations 1 - gc ;

! Printing an overview of heap usage.

: kb.
    1024 /i number>string
    6 CHAR: \s pad-left  write
    " KB" write ;

: (room.) ( free total -- )
    2dup swap - swap ( free used total )
    kb. " total " write
    kb. " used " write
    kb. " free" print ;

: room. ( -- )
    room
    0 swap [
        "Generation " write over pprint ":" write
        first2 (room.) 1+
    ] each drop
    "Semi-space:  " write kb. terpri
    "Cards:       " write kb. terpri
    "Code space:  " write (room.) ;

! Some words for iterating through the heap.

: (each-object) ( quot -- )
    next-object dup
    [ swap [ call ] keep (each-object) ] [ 2drop ] if ; inline

: each-object ( quot -- )
    [ begin-scan [ (each-object) ] keep ]
    [ end-scan ] cleanup drop ; inline

: (instances) ( obj quot seq -- )
    >r over >r call [ r> r> push ] [ r> r> 2drop ] if ; inline

: instances ( quot -- seq )
    10000 <vector> [
        -rot [ (instances) ] 2keep
    ] each-object nip ; inline

G: each-slot ( obj quot -- )
    1 standard-combination ; inline

M: array each-slot ( array quot -- ) each ;

M: object each-slot ( obj quot -- )
    over class "slots" word-prop [
        -rot [ >r swap first slot r> call ] 2keep
    ] each 2drop ;

: refers? ( to obj -- ? )
    f swap [ pick eq? or ] each-slot nip ;

: references ( obj -- list )
    [ dupd refers? ] instances nip ;

: hash+ ( n key hash -- )
    [ hash [ 0 ] unless* + ] 2keep set-hash ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap class rot hash+ ] keep
    1 swap class rot hash+ ;

: heap-stats ( -- counts sizes )
    #! Return a list of instance count/total size pairs.
    H{ } clone H{ } clone
    [ >r 2dup r> heap-stat-step ] each-object ;

: heap-stat. ( instances bytes class -- )
    pprint ": " write
    pprint " bytes, " write
    pprint " instances" print ;

: heap-stats. ( -- )
    heap-stats dup hash-keys natural-sort [
        ( hash hash key -- )
        [ [ pick hash ] keep pick hash ] keep heap-stat.
    ] each 2drop ;
