! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel
DEFER: callcc1
DEFER: continue-with

IN: errors
USING: kernel-internals lists sequences ;

! This is a very lightweight exception handling system.

TUPLE: no-method object generic ;

: no-method ( object generic -- ) <no-method> throw ;

: catchstack ( -- cs ) 6 getenv ;
: set-catchstack ( cs -- ) 6 setenv ;

: >c ( catch -- ) catchstack cons set-catchstack ;
: c> ( catch -- ) catchstack uncons set-catchstack ;

: catch ( try -- exception/f | try: -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack
    #! and push the exception. Otherwise, the data stack is
    #! not restored, and f is pushed.
    [ >c call f c> drop f ] callcc1 nip ; inline

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    catchstack empty? [
        die "Can't happen" throw
    ] [
        c> continue-with
    ] ifte ;

: cleanup ( try cleanup -- | try: -- | cleanup: -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack
    #! and run the cleanup quotation. Then throw the error to
    #! the next outermost catch handler.
    >r [ dup slip ] catch nip r>
    swap slip [ rethrow ] when* ; inline

: recover ( try recovery -- | try: -- | recovery: -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack,
    #! push the exception on the datastack, and call the
    #! recovery quotation.
    >r catch r> when* ; inline

GENERIC: error. ( error -- )
