! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: errors
USING: kernel kernel-internals lists sequences ;

! This is a very lightweight exception handling system.

TUPLE: no-method object generic ;

: no-method ( object generic -- ) <no-method> throw ;

: >c ( continuation -- ) catchstack* push ;
: c> ( -- continuation ) catchstack* pop ;

: catch ( try -- exception/f | try: -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack
    #! and push the exception. Otherwise, the data stack is
    #! not restored, and f is pushed.
    [ >c call f c> drop f ] callcc1 nip ; inline

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    catchstack empty?
    [ die "Can't happen" throw ] [ c> continue-with ] if ;

: cleanup ( try cleanup -- | try: -- | cleanup: -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack
    #! and run the cleanup quotation. Then throw the error to
    #! the next outermost catch handler.
    [ >c >r call c> drop r> call ]
    [ drop (continue-with) >r nip call r> rethrow ] ifcc ; inline

: recover ( try recovery -- | try: -- | recovery: error -- )
    #! Call the try quotation. If an exception is thrown in the
    #! dynamic extent of the quotation, restore the datastack,
    #! push the exception on the datastack, and call the
    #! recovery quotation.
    [ >c drop call c> drop ]
    [ drop (continue-with) rot drop swap call ] ifcc ; inline

GENERIC: error. ( error -- )
