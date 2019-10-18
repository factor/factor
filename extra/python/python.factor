USING: alien alien.c-types alien.data alien.libraries
arrays assocs command-line fry
hashtables init io.encodings.utf8 kernel namespaces
python.errors python.ffi python.objects sequences
specialized-arrays strings vectors ;
IN: python
QUALIFIED: math

ERROR: python-error type message traceback ;

SPECIALIZED-ARRAY: void*

! Borrowed from unix.utilities
: strings>alien ( strings encoding -- array )
    '[ _ malloc-string ] void*-array{ } map-as f suffix ;

! Initialization and finalization
: py-initialize ( -- )
    Py_IsInitialized [
        Py_Initialize
        ! Encoding must be 8bit on Windows I think, so
        ! native-string-encoding (utf16n) doesn't work.
        (command-line) [ length ] [ utf8 strings>alien ] bi 0 PySys_SetArgvEx
    ] unless ;

: py-finalize ( -- )
    Py_IsInitialized [ Py_Finalize ] when ;

! Importing
: py-import ( str -- module )
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
    dup py-tuple-size <iota> [ py-tuple-get-item ] with map ;

: py-list>vector ( py-list -- vector )
    dup py-list-size <iota> [ py-list-get-item ] with V{ } map-as ;

DEFER: >py

GENERIC: >py ( obj -- py-obj )
M: string >py
    utf8>py-unicode check-new-ref ;
M: math:fixnum >py
    PyLong_FromLong check-new-ref ;
M: math:float >py
    PyFloat_FromDouble check-new-ref ;
M: array >py
    [ >py ] map array>py-tuple ;
M: hashtable >py
    <py-dict> swap dupd [
        swapd [ >py ] bi@ py-dict-set-item
    ] with assoc-each ;
M: vector >py
    [ >py ] map vector>py-list ;
M: f >py
    drop <none> ;

! Data marshalling to Factor
SYMBOL: py-type-dispatch

DEFER: py>

: init-py-type-dispatch ( -- table )
    H{
        { "NoneType" [ drop f ] }
        { "bool" [ PyObject_IsTrue 1 = ] }
        { "dict" [ PyDict_Items (check-ref) py> >hashtable ] }
        { "int" [ PyInt_AsLong ] }
        { "list" [ py-list>vector [ py> ] map ] }
        { "long" [ PyLong_AsLong ] }
        { "str" [ PyString_AsString (check-ref) ] }
        { "tuple" [ py-tuple>array [ py> ] map ] }
        { "unicode" [ py-unicode>utf8 ] }
    } clone ;

py-type-dispatch [ init-py-type-dispatch ] initialize

ERROR: missing-type type ;

: py> ( py-obj -- obj )
    dup "__class__" getattr "__name__" getattr PyString_AsString
    py-type-dispatch get ?at [ call( x -- x ) ] [ missing-type ] if ;

! Callbacks
: quot>py-callback ( quot: ( args kw -- ret ) -- alien )
    '[
        nipd
        [ [ py> ] [ { } ] if* ] bi@ @ >py
    ] PyCallback ; inline

: with-quot>py-cfunction ( alien quot -- )
    '[ <py-cfunction> @ ] with-callback ; inline

: python-dll-loaded? ( -- ? )
    "Py_IsInitialized" "python" dlsym? ;

[ python-dll-loaded? [ py-initialize ] when ] "python" add-startup-hook
[ python-dll-loaded? [ py-finalize ] when ] "python" add-shutdown-hook
