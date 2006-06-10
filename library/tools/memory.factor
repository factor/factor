! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: memory
USING: arrays errors generic hashtables io kernel
kernel-internals math namespaces parser prettyprint
sequences strings vectors words ;

: full-gc ( -- ) generations 1- gc ;

! Printing an overview of heap usage.

: total/used/free, ( free total str -- )
    [
        ,
        dup number>string ,
        over - number>string ,
        number>string ,
    ] { } make , ;

: total, ( n str -- )
    [ , number>string , "" , "" , ] { } make , ;

: room-table ( -- table )
    room [
        { "" "Total" "Used" "Free" } ,
        0 [
            "Generation " pick number>string append
            >r first2 r> total/used/free, 1+
        ] reduce drop
        "Semi-space" total,
        "Cards" total,
        "Code space" total/used/free,
    ] [ ] make ;

: room. ( -- )
    room-table H{ } [ write ] tabular-output ;

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

: heap-stats. ( -- )
    heap-stats dup hash-keys natural-sort [
        { "Class" "Bytes" "Instances" } ,
        [
            ( hash hash key -- )
            [ dup , dup pick hash , pick hash , ] { } make ,
        ] each 2drop
    ] { } make
    H{ } [ dup string? [ write ] [ pprint ] if ]
    tabular-output ;
