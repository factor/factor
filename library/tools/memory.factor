! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: memory
USING: arrays errors generic hashtables io kernel
kernel-internals lists math namespaces parser prettyprint
sequences strings vectors words ;

: generations ( -- n ) 15 getenv ;

: full-gc ( -- ) generations 1 - gc ;

: image ( -- path )
    #! Current image name.
    16 getenv ;

: save
    #! Save the current image.
    image save-image ;

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
        uncons (room.) 1+
    ] each drop
    "Semi-space:  " write kb. terpri
    "Cards:       " write kb. terpri
    "Code space:  " write (room.) ;

! Some words for iterating through the heap.

: (each-object) ( quot -- )
    next-object dup
    [ swap [ call ] keep (each-object) ] [ 2drop ] if ; inline

: each-object ( quot -- )
    #! Applies the quotation to each object in the image.
    [ begin-scan [ (each-object) ] keep ]
    [ end-scan ] cleanup drop ; inline

: (instances) ( obj quot seq -- )
    >r over >r call [ r> r> push ] [ r> r> 2drop ] if ; inline

: instances ( quot -- seq )
    #! Return a vector of all objects that return true when the
    #! quotation is applied to them.
    10000 <vector> [
        -rot [ (instances) ] 2keep
    ] each-object nip ; inline

G: each-slot ( obj quot -- )
    [ over ] standard-combination ; inline

M: array each-slot ( array quot -- ) each ;

M: object each-slot ( obj quot -- )
    over class "slots" word-prop [
        -rot [ >r swap first slot r> call ] 2keep
    ] each 2drop ;

: refers? ( to obj -- ? )
    f swap [ pick eq? or ] each-slot nip ;

: references ( obj -- list )
    #! Return a list of all objects that refer to a given object
    #! in the image. If only one reference exists, find
    #! something referencing that, and so on.
    [ dupd refers? ] instances nip ;

: seq+ ( n index vector -- )
    [ nth + ] 2keep set-nth ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap type rot seq+ ] keep
    1 swap type rot seq+ ;

: heap-stats ( -- counts sizes )
    #! Return a list of instance count/total size pairs.
    num-types 0 <array> num-types 0 <array>
    [ >r 2dup r> heap-stat-step ] each-object ;

: heap-stat. ( { instances bytes type } -- )
    dup first zero? [
        dup third type>class pprint ": " write
        dup second pprint " bytes, " write
        dup first pprint " instances" print
    ] unless drop ;

: heap-stats. ( -- )
    #! Print heap allocation breakdown.
    heap-stats dup length 3array flip [ heap-stat. ] each ;
