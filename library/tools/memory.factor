! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: memory
USING: errors generic hashtables io kernel kernel-internals
lists math namespaces parser prettyprint sequences strings
unparser vectors words ;

: generations 15 getenv ;

: full-gc generations 1 - gc ;

: save
    #! Save the current image.
    "image" get save-image ;

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
        uncons (room.) 1 +
    ] each drop
    "Semi-space:  " write kb. terpri
    "Cards:       " write kb. terpri
    "Code space:  " write (room.) ;

! Some words for iterating through the heap.

: (each-object) ( quot -- )
    next-object [ swap [ call ] keep (each-object) ] when* ;
    inline

: each-object ( quot -- )
    #! Applies the quotation to each object in the image. We
    #! use the lower-level >c and c> words here to avoid
    #! copying the stacks.
    [ end-scan rethrow ] >c
    begin-scan (each-object) drop
    f c> call ; inline

: instances ( quot -- list )
    #! Return a list of all object that return true when the
    #! quotation is applied to them.
    [
        [
            [ swap call ] 2keep rot [ , ] [ drop ] ifte
        ] each-object drop
    ] [ ] make ;

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
    num-types zero-vector num-types zero-vector
    [ >r 2dup r> heap-stat-step ] each-object ;

: heap-stat. ( type instances bytes -- )
    dup 0 = [
        3drop
    ] [
        rot type>class word-name write ": " write
        pprint " bytes, " write
        pprint " instances" print
    ] ifte ;

: heap-stats. ( -- )
    #! Print heap allocation breakdown.
    0 heap-stats [ >r >r dup r> r> heap-stat. 1 + ] 2each drop ;

: orphans ( word -- list )
    #! Orphans are forgotten but still referenced.
    [ word? ] instances [ interned? not ] subset ;
