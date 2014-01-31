USING: alien.c-types alien.data kernel python.ffi ;
IN: python.errors

ERROR: python-error type message ;

<PRIVATE

: get-error ( -- ptype pvalue )
    { void* void* void* } [ PyErr_Fetch ] with-out-parameters drop ;

: throw-error ( ptype pvalue -- )
    [ "__name__" PyObject_GetAttrString ] [ PyObject_Str ] bi*
    [ &Py_DecRef PyString_AsString ] bi@ python-error ;

PRIVATE>

: (check-ref) ( ref -- ref' )
    [ get-error throw-error f ] unless* ;

: check-new-ref ( ref -- ref' )
    &Py_DecRef (check-ref) ;

: check-borrowed-ref ( ref -- ref' )
    dup Py_IncRef &Py_DecRef (check-ref) ;

: check-zero ( code -- )
    0 = [ get-error throw-error ] unless ;

: unsteal-ref ( ref -- ref' )
    dup Py_IncRef ;
