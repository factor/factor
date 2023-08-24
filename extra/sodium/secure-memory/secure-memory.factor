! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING:
    accessors alien combinators.short-circuit continuations destructors kernel
    libc
    sodium sodium.ffi
;

IN: sodium.secure-memory

TUPLE: secure-memory < disposable
    size underlying ;

: new-secure-memory ( size -- obj )
    dup sodium-malloc secure-memory new-disposable
    swap >>underlying swap >>size ;

: allow-no-access ( secure-memory -- )
    check-disposed underlying>> sodium_mprotect_noaccess check0 ;

: allow-read-access ( secure-memory -- )
    check-disposed underlying>> sodium_mprotect_readonly check0 ;

: with-read-access ( ..a secure-memory quot: ( ..a secure-memory -- ..b ) -- ..b )
    over dup allow-read-access [ allow-no-access ] curry finally ; inline

: allow-write-access ( secure-memory -- )
    check-disposed underlying>> sodium_mprotect_readwrite check0 ;

: with-write-access ( ..a secure-memory quot: ( ..a secure-memory -- ..b ) -- ..b )
    over dup allow-write-access [ allow-no-access ] curry finally ; inline

: with-new-secure-memory ( ..a size quot: ( ..a secure-memory -- ..b ) -- ..b )
    [ new-secure-memory ] dip with-write-access ; inline

: secure-memory= ( a b -- ? )
    [ check-disposed ] bi@ {
        [ [ size>> ] bi@ = ]
        [ [ [ >c-ptr ] bi@ ] keep size>> sodium_memcmp 0 = ]
    } 2&& ;

M: secure-memory dispose* ( disposable -- )
    [ sodium_free f ] change-underlying f swap size<<  ;

M: secure-memory byte-length ( obj -- n )
    size>> ;

M: secure-memory clone ( obj -- cloned )
    check-disposed [
        size>> new-secure-memory dup underlying>>
    ] [ underlying>> ] [ size>> ] tri memcpy ;
