! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel DEFER: callcc1
IN: streams DEFER: line-number
IN: parser DEFER: file
IN: errors USING: kernel-internals lists namespaces streams ;

TUPLE: no-method object generic ;

: no-method ( object generic -- )
    #! We 2dup here to leave both values on the stack, for
    #! post-mortem inspection.
    2dup <no-method> throw ;

! This is a very lightweight exception handling system.

: catchstack ( -- cs ) 6 getenv ;
: set-catchstack ( cs -- ) 6 setenv ;

: >c ( catch -- ) catchstack cons set-catchstack ;
: c> ( catch -- ) catchstack uncons set-catchstack ;

: save-error ( error -- )
    #! Save the stacks and parser state for post-mortem
    #! inspection after an error.
    namespace [
        "col" get
        "line" get
        line-number get
        file get
        global [
            "error-file" set
            "error-line-number" set
            "error-line" set
            "error-col" set
            "error" set
            datastack "error-datastack" set
            callstack "error-callstack" set
            namestack "error-namestack" set
            catchstack "error-catchstack" set
        ] bind
    ] when ;

: catch ( try catch -- )
    #! Call the try quotation. If an error occurs restore the
    #! datastack, push the error, and call the catch block.
    #! If no error occurs, push f and call the catch block.
    [ >c >r call c> drop f r> f ] callcc1 rot drop swap call ;

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    #! For convinience, this word is a no-op if error is f.
    [ c> call ] when* ;
