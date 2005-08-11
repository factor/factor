! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inspector
USING: generic hashtables io kernel kernel-internals lists math
memory namespaces prettyprint sequences strings styles test
unparser vectors words ;

SYMBOL: inspecting

GENERIC: sheet ( obj -- sheet )

M: object sheet ( obj -- sheet )
    dup class "slots" word-prop
    [ second ] map
    tuck [ execute ] map-with
    2list ;

PREDICATE: list nonvoid cons? ;

M: nonvoid sheet unit ;

M: vector sheet unit ;

M: array sheet unit ;

M: hashtable sheet dup hash-keys swap hash-values 2list ;

: format-column ( list -- list )
    [ unparse ] map
    [ max-length ] keep
    [ swap CHAR: \s pad-right ] map-with ;

: format-sheet ( sheet -- list )
    dup first length >vector swons
    dup peek over first [ set ] 2each
    [ format-column ] map
    flip
    [ " | " join ] map ;

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

GENERIC: extra-banner ( obj -- )

M: word extra-banner ( obj -- )
    dup vocab-banner
    metaclass [
        "This is a class whose behavior is specifed by the " write
        unparse. " metaclass." print
    ] when* ;

M: object extra-banner ( obj -- ) drop ;

: inspect-banner ( obj -- )
    "You are looking at an instance of the " write dup class unparse.
    " class:" print
    "  " write dup unparse. terpri
    "It takes up " write dup size unparse write " bytes of memory." print
    extra-banner ;

: describe ( obj -- )
    sheet dup format-sheet
    swap peek [ presented swons unit ] map
    [ format terpri ] 2each ;

: inspect ( obj -- )
    dup inspecting set dup inspect-banner describe ;

: go ( n -- ) get inspect ;
