USING: accessors alien alien.c-types alien.data arrays assocs fry hashtables
kernel namespaces python.errors python.ffi python.objects sequences strings
vectors ;
IN: python
QUALIFIED: math

! Initialization and finalization
: py-initialize ( -- )
    Py_IsInitialized [ Py_Initialize ] unless ;

: py-finalize ( -- )
    Py_IsInitialized [ Py_Finalize ] when ;

! Importing
: import ( str -- module )
    PyImport_ImportModule check-new-ref ;

! Unicodes
: py-ucs-size ( -- n )
    "maxunicode" PySys_GetObject PyInt_AsLong 0xffff = 2 4 ? ;

: py-unicode>utf8 ( uni -- str )
    py-ucs-size 4 =
    [ PyUnicodeUCS4_AsUTF8String ]
    [ PyUnicodeUCS2_AsUTF8String ] if (check-ref)
    PyString_AsString (check-ref) ;

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

: py-list>vector ( py-list -- vector )
    dup py-list-size iota [ py-list-get-item ] with V{ } map-as ;

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

: >py ( obj -- py-obj )
    (>py) &Py_DecRef ;

! Data marshalling to Factor
SYMBOL: py-type-dispatch

DEFER: >factor

: init-py-type-dispatch ( -- table )
    H{
        { "NoneType" [ drop f ] }
        { "bool" [ PyObject_IsTrue 1 = ] }
        { "dict" [ PyDict_Items (check-ref) >factor >hashtable ] }
        { "int" [ PyInt_AsLong ] }
        { "list" [ py-list>vector [ >factor ] map ] }
        { "long" [ PyLong_AsLong ] }
        { "str" [ PyString_AsString (check-ref) ] }
        { "tuple" [ py-tuple>array [ >factor ] map ] }
        { "unicode" [ py-unicode>utf8 ] }
    } clone ;

py-type-dispatch [ init-py-type-dispatch ] initialize

ERROR: missing-type type ;

: >factor ( py-obj -- obj )
    dup "__class__" getattr "__name__" getattr PyString_AsString
    py-type-dispatch get ?at [ call( x -- x ) ] [ missing-type ] if ;
