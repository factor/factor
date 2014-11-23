USING: alien.c-types alien.data kernel python.ffi vocabs.loader words ;
IN: python.errors

<PRIVATE

: get-error ( -- ptype pvalue ptraceback )
    { void* void* void* } [ PyErr_Fetch ] with-out-parameters ;

! Breaking out of a circular dependency.
: throw-error ( ptype pvalue ptraceback -- )
    "throw-error" "python.throwing" lookup-word execute( a b c -- ) ;

PRIVATE>

: (check-ref) ( ref -- ref )
    [ get-error throw-error f ] unless* ;

: check-new-ref ( ref -- ref )
    &Py_DecRef (check-ref) ;

: check-borrowed-ref ( ref -- ref )
    dup Py_IncRef &Py_DecRef (check-ref) ;

: check-zero ( code -- )
    0 = [ get-error throw-error ] unless ;

: unsteal-ref ( ref -- ref )
    dup Py_IncRef ;
