! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: memory
USING: kernel-internals errors generic kernel lists math
namespaces prettyprint stdio unparser vectors words ;

! Printing an overview of heap usage.

: kb. 1024 /i unparse write " KB" write ;

: (room.) ( free total -- )
    2dup swap - swap ( free used total )
    kb. " total " write
    kb. " used " write
    kb. " free" print ;

: room. ( -- )
    room
    "Data space: " write (room.)
    "Code space: " write (room.) ;

! Some words for iterating through the heap.

: (each-object) ( quot -- )
    next-object dup [
        swap dup slip (each-object)
    ] [
        2drop
    ] ifte ; inline

: each-object ( quot -- )
    #! Applies the quotation to each object in the image.
    [
        begin-scan (each-object)
    ] [
        end-scan rethrow
    ] catch ; inline

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
    dup class "slots" word-property [
        pick pick >r >r car slot swap call r> r>
    ] each 2drop ;

: each-slot ( obj quot -- )
    #! Apply the quotation to each slot value of the object.
    swap (each-slot) ; inline

: refers? ( to obj -- ? )
    f swap [ pick eq? or ] each-slot nip ;

: references ( obj -- list )
    #! Return a list of all objects that refer to a given object
    #! in the image.
    [ dupd refers? ] instances nip ;

: vector+ ( n index vector -- )
    [ vector-nth + ] 2keep set-vector-nth ;

: heap-stat-step ( counts sizes obj -- )
    [ dup size swap type rot vector+ ] keep
    1 swap type rot vector+ ;

: zero-vector ( n -- vector )
    [ drop 0 ] vector-project ;

: heap-stats ( -- stats )
    #! Return a list of instance count/total size pairs.
    num-types zero-vector num-types zero-vector
    [ >r 2dup r> heap-stat-step ] each-object
    swap vector>list swap vector>list zip ;

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
