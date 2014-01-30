USING: accessors alien alien.c-types alien.data arrays assocs fry grouping
hashtables kernel namespaces python.ffi sequences strings vectors words ;
IN: python
QUALIFIED: math

! Initialization and finalization
: py-initialize ( -- )
    Py_IsInitialized [ Py_Initialize ] unless ;

: py-finalize ( -- )
    Py_IsInitialized [ Py_Finalize ] when ;

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
    (check-return) &Py_DecRef ;

: check-return-code ( return -- )
    0 = [ get-error throw-error ] unless ;

! Importing
: import ( str -- module )
    PyImport_ImportModule check-return ;

! Objects
: getattr ( obj str -- value )
    PyObject_GetAttrString check-return ;

: setattr ( obj str value -- )
    PyObject_SetAttrString check-return-code ;

: call-object ( obj args -- value )
    PyObject_CallObject check-return ;

! Types
: <py-tuple> ( length -- tuple )
    PyTuple_New check-return ;

: py-tuple-set-item ( obj pos val -- )
    dup Py_IncRef PyTuple_SetItem check-return-code ;

: py-tuple-get-item ( obj pos -- val )
    PyTuple_GetItem dup Py_IncRef check-return ;

: py-tuple-size ( obj -- len )
    PyTuple_Size ;

: <1py-tuple> ( alien -- tuple )
    1 <py-tuple> [ 0 rot py-tuple-set-item ] keep ;

! Dicts
: <py-dict> ( -- dict )
    PyDict_New check-return ;

: py-dict-set-item ( obj key val -- )
    PyDict_SetItem check-return-code ;

: py-dict-set-item-string ( dict key val -- )
    PyDict_SetItemString check-return-code ;

: py-dict-get-item-string ( obj key -- val )
    PyDict_GetItemString dup Py_IncRef check-return ;

: py-dict-size ( obj -- len )
    PyDict_Size ;

! Lists
: <py-list> ( length -- list )
    PyList_New check-return ;

: py-list-size ( list -- len )
    PyList_Size ;

: py-list-get-item ( obj pos -- val )
    PyList_GetItem dup Py_IncRef check-return ;

: py-list-set-item ( obj pos val -- )
    dup Py_IncRef PyList_SetItem check-return-code ;

! Unicodes
: py-ucs-size ( -- n )
    "maxunicode" PySys_GetObject PyInt_AsLong 0xffff = 2 4 ? ;

: py-unicode>utf8 ( uni -- str )
    py-ucs-size 4 =
    [ PyUnicodeUCS4_AsUTF8String ]
    [ PyUnicodeUCS2_AsUTF8String ] if (check-return)
    PyString_AsString (check-return) ;

: utf8>py-unicode ( str -- uni )
    py-ucs-size 4 =
    [ PyUnicodeUCS4_FromString ]
    [ PyUnicodeUCS2_FromString ] if ;

! Data marshalling to Python
: array>py-tuple ( arr -- py-tuple )
    [ length <py-tuple> dup ] keep
    [ rot py-tuple-set-item ] with each-index ;

: vector>py-list ( vec -- py-list )
    [ length <py-list> dup ] keep
    [ rot py-list-set-item ] with each-index ;

: py-tuple>array ( py-tuple -- arr )
    dup py-tuple-size iota [ py-tuple-get-item ] with map ;

GENERIC: (>py) ( obj -- obj' )
M: string (>py) utf8>py-unicode ;
M: math:fixnum (>py) PyLong_FromLong ;
M: math:float (>py) PyFloat_FromDouble ;
M: array (>py) [ (>py) ] map array>py-tuple ;
M: hashtable (>py)
    <py-dict> swap dupd [
        swapd [ (>py) ] [ (>py) ] bi* py-dict-set-item
    ] with assoc-each ;
M: vector (>py)
    [ (>py) ] map vector>py-list ;

M: word (>py) name>> (>py) ;

: >py ( obj -- py-obj )
    (>py) &Py_DecRef ;

! Data marshalling to Factor
SYMBOL: py-type-dispatch

DEFER: >factor

: init-py-type-dispatch ( -- table )
    H{
        { "NoneType" [ drop f ] }
        { "bool" [ PyObject_IsTrue 1 = ] }
        { "dict" [ PyDict_Items (check-return) >factor >hashtable ] }
        { "int" [ PyInt_AsLong ] }
        { "list" [
            dup py-list-size iota [ py-list-get-item >factor ] with V{ } map-as
        ] }
        { "long" [ PyLong_AsLong ] }
        { "str" [ PyString_AsString (check-return) ] }
        { "tuple" [ py-tuple>array [ >factor ] map ] }
        { "unicode" [ py-unicode>utf8 ] }
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
