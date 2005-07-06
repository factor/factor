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
    dup third over first zip [ uncons set ] each
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

: inspect-banner ( obj -- )
    "Inspecting " write dup class unparse a/an.
    " with representation " write dup unparse write "," print
    "located at address " write dup address >hex write
    ", consuming " write size unparse write
    " bytes of memory." print ;

: inspect ( obj -- )
    dup inspect-banner
    dup inspecting set
    describe [ print ] each ;
