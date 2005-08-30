! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
USING: kernel-internals lists ;
DEFER: callcc1
IN: errors

! This is a very lightweight exception handling system.

TUPLE: no-method object generic ;

: no-method ( object generic -- ) <no-method> throw ; inline

: catchstack ( -- cs ) 6 getenv ;
: set-catchstack ( cs -- ) 6 setenv ;

: >c ( catch -- ) catchstack cons set-catchstack ;
: c> ( catch -- ) catchstack uncons set-catchstack ;

: catch ( try catch -- )
    #! Call the try quotation. If an error occurs restore the
    #! datastack, push the error, and call the catch block.
    #! If no error occurs, push f and call the catch block.
    [ >c >r call c> drop f r> f ] callcc1 rot drop swap call ;

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    #! For convinience, this word is a no-op if error is f.
    [ c> call ] when* ;

GENERIC: error. ( error -- )
