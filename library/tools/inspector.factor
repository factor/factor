! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: generic hashtables io kernel kernel-internals lists math
memory namespaces prettyprint sequences strings test unparser
vectors words ;

SYMBOL: inspecting

GENERIC: sheet ( obj -- sheet )

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    [ second ] map
    tuck [ execute ] map-with 2list ;

PREDICATE: list nonvoid cons? ;

M: nonvoid sheet >list unit ;

M: vector sheet >list unit ;

M: array sheet >list unit ;

M: hashtable sheet hash>alist unzip 2list ;

: column ( list -- list )
    [ unparse ] map
    [ [ length ] map 0 [ max ] reduce ] keep
    [ swap CHAR: \s pad-right ] map-with ;

: describe ( obj -- list )
    sheet dup first length count swons
    dup peek over first zip [ uncons set ] each
    [ column ] map
    seq-transpose
    [ " " join ] map ;

: (join) ( list glue -- )
    over [
        over car % >r cdr dup
        [ r> dup % (join) ] [ r> 2drop ] ifte
    ] [
        2drop
    ] ifte ;

: join ( list glue -- seq )
    #! The new sequence is of the same type as glue.
    [ [ (join) ] make-vector ] keep like ;

: a/an ( noun -- str )
    first "aeiouAEIOU" contains? "an " "a " ? ;

: a/an. ( noun -- )
    dup a/an write write ;

: interned? ( word -- ? )
    dup word-name swap word-vocabulary vocab hash ;

: class-banner ( word -- )
    dup metaclass dup [
        "This is a class whose behavior is specifed by the " write
        unparse write " metaclass," print
        "currently having " write
        "predicate" word-prop instances length unparse write
        " instances." print
    ] [
        2drop
    ] ifte ;

: vocab-banner ( word -- )
    dup word-vocabulary [
        dup interned? [
            "This word is located in the " write
        ] [
            "This is an orphan not part of the dictionary." print
            "It claims to belong to the " write
        ] ifte
        word-vocabulary unparse write " vocabulary." print
    ] [
        drop
        "The word is a uniquely generated symbol." print
    ] ifte ;

M: word extra-banner ( obj -- )
    dup vocab-banner swap class-banner ;

M: object extra-banner ( obj -- ) drop ;

: inspect-banner ( obj -- )
    dup references length >r
    "You are looking at " write dup class unparse a/an.
    " object with the following printed representation:" print
    "  " write dup unparse print
    "It is located at address " write dup address >hex write
    " and takes up " write dup size unparse write
    " bytes of memory." print
    "This object is referenced from " write r> unparse write
    " other objects in the heap." print
    extra-banner ;

: inspect ( obj -- )
    dup inspect-banner
    dup inspecting set
    describe [ print ] each ;
