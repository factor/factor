USING:
    accessors
    alien alien.c-types alien.data
    arrays
    assocs
    destructors
    fry
    grouping
    hashtables
    kernel
    namespaces
    python.ffi
    sequences
    strings
    words ;
IN: python
QUALIFIED: math

! Error handling
ERROR: python-error type message ;

: get-error ( -- ptype pvalue )
    { void* void* void* } [ PyErr_Fetch ] with-out-parameters drop ;

: throw-error ( ptype pvalue -- )
    [ "__name__" PyObject_GetAttrString ] [ PyObject_Str ] bi* [ &Py_DecRef ] bi@
    [ PyString_AsString ] bi@ python-error ;

: (check-return) ( value/f -- value' )
    [ get-error throw-error f ] unless* ;

: check-return ( value/f -- value' )
    (check-return) ; ! &Py_DecRef ;

: check-return-code ( return -- )
    0 = [ get-error throw-error ] unless ;

! Importing
: import ( str -- module )
    PyImport_ImportModule check-return ;

! Objects
: getattr ( obj str -- value )
    PyObject_GetAttrString check-return ;

: call-object ( obj args -- value )
    PyObject_CallObject check-return ;

! Context
: with-py ( quot -- )
    '[ Py_Initialize _ call Py_Finalize ] with-destructors ; inline

! Types and their methods
: <py-tuple> ( length -- tuple )
    PyTuple_New check-return ;

: py-tuple-set-item ( obj pos val -- )
    PyTuple_SetItem check-return-code ;

: py-tuple-get-item ( obj pos -- val )
    PyTuple_GetItem check-return ;

: py-tuple-size ( obj -- len )
    PyTuple_Size ;

: <py-dict> ( -- dict )
    PyDict_New check-return ;

: py-dict-set-item ( obj key val -- )
    PyDict_SetItem check-return-code ;

: py-dict-set-item-string ( dict key val -- )
    PyDict_SetItemString check-return-code ;

: py-dict-get-item-string ( obj key -- val )
    PyDict_GetItemString check-return ;

: py-dict-size ( obj -- len )
    PyDict_Size ;

: py-list-size ( list -- len )
    PyList_Size ;

: py-list-get-item ( obj pos -- val )
    PyList_GetItem check-return ;

! Data marshalling to Python
GENERIC: (>py) ( obj -- obj' )
M: string (>py) PyUnicodeUCS2_FromString ;
M: math:fixnum (>py) PyLong_FromLong ;
M: math:float (>py) PyFloat_FromDouble ;

M: array (>py)
    [ length <py-tuple> dup ] [ [ (>py) ] map ] bi
    [ rot py-tuple-set-item ] with each-index ;

M: hashtable (>py)
    <py-dict> swap dupd [
        swapd [ (>py) ] [ (>py) ] bi* py-dict-set-item
    ] with assoc-each ;

! I'll make a fast-path for this
M: word (>py) name>> (>py) ;

: >py ( obj -- py-obj )
    (>py) ; ! &Py_DecRef ;

! Data marshalling to Factor
SYMBOL: py-type-dispatch

DEFER: >factor

: init-py-type-dispatch ( -- table )
    H{
        { "NoneType" [ drop f ] }
        { "dict" [ PyDict_Items (check-return) >factor >hashtable ] }
        { "int" [ PyInt_AsLong ] }

        { "list" [
            dup py-list-size iota [ py-list-get-item >factor ] with map
        ] }
        { "long" [ PyLong_AsLong ] }
        { "str" [ PyString_AsString (check-return) ] }
        { "tuple" [
            dup py-tuple-size iota [ py-tuple-get-item >factor ] with map
        ] }
        { "unicode" [
            PyUnicodeUCS2_AsUTF8String (check-return)
            PyString_AsString (check-return)
        ] }
    } clone ;

py-type-dispatch [ init-py-type-dispatch ] initialize

ERROR: missing-type type ;

: >factor ( py-obj -- obj )
    dup "__class__" getattr "__name__" getattr PyString_AsString
    py-type-dispatch get ?at [ call( x -- x ) ] [ missing-type ] if ;

! Utility
: py-call ( obj args -- value )
    >py call-object >factor ;

: py-call2 ( obj args kwargs -- value )
    [ >py ] [ 2 group >hashtable >py ] bi* PyObject_Call >factor ;
