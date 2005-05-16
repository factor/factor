! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: memory
USING: errors generic hashtables kernel kernel-internals lists
math namespaces prettyprint sequences stdio strings unparser
vectors words ;

: generations 15 getenv ;

: full-gc generations 1 - gc ;

: save
    #! Save the current image.
    "image" get save-image ;

! Printing an overview of heap usage.

: kb. 1024 /i unparse 6 CHAR: \s pad  write " KB" write ;

: (room.) ( free total -- )
    2dup swap - swap ( free used total )
    kb. " total " write
    kb. " used " write
    kb. " free" print ;

: room. ( -- )
    room
    0 swap [
        "Generation " write over unparse write ":" write
        uncons (room.) 1 +
    ] each drop
    "Semi-space:  " write kb. terpri
    "Cards:       " write kb. terpri
    "Code space:  " write (room.) ;

! Some words for iterating through the heap.

: each-object ( quot -- )
    #! Applies the quotation to each object in the image. We
    #! use the lower-level >c and c> words here to avoid
    #! copying the stacks.
    [ end-scan rethrow ] >c
    begin-scan [ next-object ] while
    f c> call ;

: instances ( quot -- list )
    #! Return a list of all object that return true when the
    #! quotation is applied to them.
    [
        [
            [ swap call ] 2keep rot [ , ] [ drop ] ifte
        ] each-object drop
    ] make-list ;

GENERIC: (each-slot) ( quot obj -- ) inline

M: arrayed (each-slot) ( quot array -- )
    dup array-capacity [
        [
            ( quot obj n -- )
            swap array-nth swap dup slip
        ] 2keep
    ] repeat 2drop ;

M: object (each-slot) ( quot obj -- )
    dup class "slots" word-prop [
        pick pick >r >r car slot swap call r> r>
    ] each 2drop ;

: each-slot ( obj quot -- )
    #! Apply the quotation to each slot value of the object.
    swap (each-slot) ; inline

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

: heap-stats ( -- stats )
    #! Return a list of instance count/total size pairs.
    num-types zero-vector num-types zero-vector
    [ >r 2dup r> heap-stat-step ] each-object
    swap >list swap >list zip ;

: heap-stat. ( type instances bytes -- )
    dup 0 = [
        3drop
    ] [
        rot builtin-type word-name write ": " write
        unparse write " bytes, " write
        unparse write " instances" print
    ] ifte ;

: heap-stats. ( -- )
    #! Print heap allocation breakdown.
    0 heap-stats [ dupd uncons heap-stat. 1 + ] each drop ;

: orphan? ( word -- ? )
    #! Test if the word is not a member of its vocabulary.
    dup dup word-name swap word-vocabulary dup [
        vocab dup [ hash eq? not ] [ 3drop t ] ifte
    ] [
        3drop t
    ] ifte ;

: orphans ( word -- list )
    #! Orphans are forgotten but still referenced.
    [ word? ] instances [ orphan? ] subset ;
