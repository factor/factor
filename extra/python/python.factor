USING: alien alien.libraries arrays assocs byte-arrays
hashtables init kernel math math.parser namespaces python.errors
python.ffi python.objects sequences strings vectors ;

IN: python

ERROR: python-error type message traceback ;

! Initialization and finalization
: py-initialize ( -- )
    Py_IsInitialized [ Py_Initialize ] unless ;

: py-finalize ( -- )
    Py_IsInitialized [ Py_Finalize ] when ;

! Importing
: py-import ( modulename -- module )
    PyImport_ImportModule check-new-ref ;

: py-import-from ( modulename objname -- obj )
    [ py-import ] [ getattr ] bi* ;

! Data marshalling to Python
: array>py-tuple ( array -- py-tuple )
    [ length <py-tuple> ] keep
    [ [ dup ] 2dip swap py-tuple-set-item ] each-index ;

: vector>py-list ( vector -- py-list )
    [ length <py-list> ] keep
    [ [ dup ] 2dip swap py-list-set-item ] each-index ;

: assoc>py-dict ( assoc -- py-dict )
    <py-dict> swap [ [ dup ] 2dip py-dict-set-item ] assoc-each ;

: py-tuple>array ( py-tuple -- arr )
    dup py-tuple-size <iota> [ py-tuple-get-item ] with map ;

: py-list>vector ( py-list -- vector )
    dup py-list-size <iota> [ py-list-get-item ] with V{ } map-as ;

: py-unicode>string ( py-unicode -- string )
    PyUnicode_AsUTF8 (check-ref) ;

: py-bytes>byte-array ( py-bytes -- byte-array )
    PyBytes_AsString (check-ref) >byte-array ;

: py-dict>hashtable ( py-dict -- hashtable )
    PyDict_Items (check-ref) py-list>vector
    [ py-tuple>array ] map >hashtable ;

: py-class-name ( py-object -- name )
    "__class__" getattr "__name__" getattr py-unicode>string ;

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
    [ [ >py ] bi@ ] assoc-map assoc>py-dict ;

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
        { "bytes" [ py-bytes>byte-array ] }
        { "dict" [ py-dict>hashtable [ [ py> ] bi@ ] assoc-map ] }
        { "int" [ PyLong_AsLong ] }
        { "list" [ py-list>vector [ py> ] map ] }
        { "str" [ py-unicode>string ] }
        { "tuple" [ py-tuple>array [ py> ] map ] }
    } clone ;

py-type-dispatch [ init-py-type-dispatch ] initialize

ERROR: missing-type type ;

: py> ( py-obj -- obj )
    dup py-class-name py-type-dispatch get ?at
    [ call( x -- x ) ] [ missing-type ] if ;

! Callbacks
: quot>py-callback ( quot: ( args kw -- ret ) -- alien )
    '[ nipd [ [ py> ] [ { } ] if* ] bi@ @ >py ] PyCallback ; inline

: with-quot>py-cfunction ( alien quot -- )
    '[ <py-cfunction> @ ] with-callback ; inline

: python-dll-loaded? ( -- ? )
    "Py_IsInitialized" "python" dlsym? ;

STARTUP-HOOK: [ python-dll-loaded? [ py-initialize ] when ]
SHUTDOWN-HOOK: [ python-dll-loaded? [ py-finalize ] when ]
