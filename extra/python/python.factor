USING: alien alien.c-types alien.data alien.libraries arrays
assocs byte-arrays command-line hashtables init
io.encodings.string io.encodings.utf8 kernel math math.parser
namespaces python.errors python.ffi python.objects sequences
specialized-arrays strings vectors ;

IN: python

ERROR: python-error type message traceback ;

SPECIALIZED-ARRAY: void*

! Initialization and finalization
: py-initialize ( -- )
    Py_IsInitialized [ Py_Initialize ] unless ;

: py-finalize ( -- )
    Py_IsInitialized [ Py_Finalize ] when ;

! Importing
: py-import ( str -- module )
    PyImport_ImportModule check-new-ref ;

! Data marshalling to Python
: array>py-tuple ( arr -- py-tuple )
    [ length <py-tuple> dup ] keep
    [ rot py-tuple-set-item ] with each-index ;

: vector>py-list ( vec -- py-list )
    [ length <py-list> dup ] keep
    [ rot py-list-set-item ] with each-index ;

DEFER: >py
DEFER: py>

: py-tuple>array ( py-tuple -- arr )
    dup py-tuple-size <iota> [ py-tuple-get-item py> ] with map ;

: py-list>vector ( py-list -- vector )
    dup py-list-size <iota> [ py-list-get-item py> ] with V{ } map-as ;

: py-unicode>string ( py-unicode -- str )
    PyUnicode_AsUTF8 (check-ref) ;

: py-bytes>byte-array ( py-bytes -- byte-array )
    PyBytes_AsString (check-ref) >byte-array ;

: py-dict>hashtable ( py-dict -- hashtable )
    PyDict_Items (check-ref) py> >hashtable ;

GENERIC: >py ( obj -- py-obj )

M: byte-array >py
    dup length PyBytes_FromStringAndSize check-new-ref ;

M: string >py
    PyUnicode_FromString check-new-ref ;

M: math:fixnum >py
    PyLong_FromLong check-new-ref ;

M: math:bignum >py
    number>string f 10 PyLong_FromString check-new-ref ;

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

: init-py-type-dispatch ( -- table )
    H{
        { "NoneType" [ drop f ] }
        { "bool" [ PyObject_IsTrue 1 = ] }
        { "bytes" [ py-bytes>byte-array ] }
        { "dict" [ py-dict>hashtable ] }
        { "int" [ PyLong_AsLong ] }
        { "list" [ py-list>vector ] }
        { "str" [ py-unicode>string ] }
        { "tuple" [ py-tuple>array ] }
    } clone ;

py-type-dispatch [ init-py-type-dispatch ] initialize

ERROR: missing-type type ;

: py> ( py-obj -- obj )
    dup "__class__" getattr "__name__" getattr py-unicode>string
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
