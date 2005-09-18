! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
DEFER: callcc1
DEFER: continue-with

IN: errors
USING: kernel-internals lists ;

! This is a very lightweight exception handling system.

TUPLE: no-method object generic ;

: no-method ( object generic -- ) <no-method> throw ;

: catchstack ( -- cs ) 6 getenv ;
: set-catchstack ( cs -- ) 6 setenv ;

: >c ( catch -- ) catchstack cons set-catchstack ;
: c> ( catch -- ) catchstack uncons set-catchstack ;

: (catch) ( try -- exception/f )
    [ >c call f c> drop f ] callcc1 nip ;

: catch ( try catch -- )
    #! Call the try quotation. If an error occurs restore the
    #! datastack, push the error, and call the catch block.
    #! If no error occurs, push f and call the catch block.
    >r (catch) r> call ;

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    #! For convinience, this word is a no-op if error is f.
    [ catchstack empty? [ die ] [ c> continue-with ] ifte ] when* ;

GENERIC: error. ( error -- )
