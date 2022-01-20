USING: accessors alien arrays assocs calendar continuations destructors
destructors.private fry kernel math memory namespaces python python.errors
python.ffi python.objects sequences strings tools.test ;
IN: python

: py-test ( result quot -- )
    '[ python-dll-loaded? [ _ [ _ with-destructors ] unit-test ] when ] call ; inline

! None testing
{ t } [
    "builtins" "None" py-import-from <none> =
] py-test

! Destructors
{ 1 } [ 33 >py drop always-destructors get length ] py-test

{ 1 } [ f >py drop always-destructors get length ] py-test

! The tuple steals the reference properly now.
{ 1 } [ 33 >py <1py-tuple> drop always-destructors get length ] py-test

{ 1 } [ { } >py drop always-destructors get length ] py-test

{ 1 } [ V{ 1 2 3 4 } >py drop always-destructors get length ] py-test

{ 2 } [
    99 >py V{ 1 2 3 4 } >py 2drop always-destructors get length
] py-test

{ 1 } [
    { { { 33 } } } >py drop always-destructors get length
] py-test

{ } [ 123 <alien> unsteal-ref ] unit-test

{ t } [ Py_GetVersion string? ] py-test

[ "os" ] [ "os" py-import PyModule_GetName ] py-test

{ t } [
    "os" py-import "getpid" getattr
    { } >py call-object py> 0 >
] py-test

{ t } [ Py_IsInitialized ] py-test

! py-importing
[ { "ModuleNotFoundError" "No module named 'kolobi'" f } ] [
    [ "kolobi" py-import ] [
        [ type>> ] [ message>> ] [ traceback>> ] tri 3array
    ] recover
] py-test

! setattr
{ 73 } [
    "sys" py-import "testit" [ 73 >py setattr ] [ getattr py> ] 2bi
] py-test

! Tuples
{ 2 } [ 2 <py-tuple> py-tuple-size ] py-test

: py-datepy> ( py-obj -- timestamp )
    { "year" "month" "day" } [ getattr py> ] with map
    first3 0 0 0 instant <timestamp> ;

! Lists
{ t } [ V{ 4 8 15 16 23 42 } dup >py py> = ] py-test

! ! Datetimes
{ t } [
    [ py-datepy> ] "date" py-type-dispatch get set-at
    "datetime" py-import "date" getattr "today" getattr
    { } >py call-object py>
    today instant >>gmt-offset =
] py-test

! Unicode
{ "غثههح" } [
    "os.path" py-import "basename" getattr { "غثههح" } >py call-object py>
] py-test

! Instance variables
{ 7 } [
    "datetime" py-import "timedelta" getattr
    { 7 } >py call-object "days" getattr py>
] py-test

! Create a dictonary
{ 0 } [ <py-dict> py-dict-size ] py-test

! Dictionary with object keys
{ 1 } [
    <py-dict> dup 0 >py 33 >py py-dict-set-item py-dict-size
] py-test

! Dictionary with string keys
{ 1 } [
    <py-dict> [ "foo" 33 >py py-dict-set-item-string ] [ py-dict-size ] bi
] py-test

! Get dictionary items
{ 33 } [
    <py-dict> "tjaba"
    [ 33 >py  py-dict-set-item-string ]
    [ py-dict-get-item-string py> ] 2bi
] py-test

! Nest dicts
{ 0 } [
    <py-dict> "foo"
    [ <py-dict> py-dict-set-item-string ]
    [ py-dict-get-item-string ] 2bi
    py-dict-size
] py-test

! Nested tuples
{ 3 } [
    1 <py-tuple> dup 0 3 <py-tuple> py-tuple-set-item
    0 py-tuple-get-item py-tuple-size
] py-test

! Round tripping!
{ { "foo" { 99 77 } } }
[ { "foo" { 99 77 } } >py py> ] py-test

{ H{ { "foo" "bar" } { 3 4 } } } [
    H{ { "foo" "bar" } { 3 4 } } >py py>
] py-test

! Kwargs
{ 2014 10 22 } [
    "datetime" py-import "date" getattr
    { } >py H{ { "year" 2014 } { "month" 10 } { "day" 22 } } >py
    call-object-full py>
    [ year>> ] [ month>> ] [ day>> ] tri
] py-test

! Modules
{ t } [
    "os" py-import PyModule_GetDict dup Py_IncRef &Py_DecRef py-dict-size 100 >
] py-test

! CFunctions
{ t } [
    1234 <alien> "foo" f <PyMethodDef>
    ml_flags>> METH_VARARGS METH_KEYWORDS bitor =
] unit-test

{ f 3 } [
    1234 <alien> <py-cfunction>
    [ "__doc__" getattr py> ] [ PyCFunction_GetFlags ] bi
] py-test

{ "cfunction" } [
    1234 <alien> <py-cfunction>
    ! Force nursery flush
    10000 [ 1000 0xff <array> drop ] times
    "__name__" getattr py>
] py-test

{ 3 } [
    1234 <alien> <py-cfunction> drop always-destructors get length
] py-test

! Callbacks
: py-map ( -- alien )
    "builtins" "map" py-import-from ;

: py-list ( -- alien )
    "builtins" "list" py-import-from ;

: py-list-call ( alien -- seq )
    py-list swap 1array array>py-tuple f call-object-full py> ;

: py-map-call ( alien-cb -- seq )
    [
        <py-cfunction> py-map swap { 1 2 } >py 2array array>py-tuple f
        call-object-full
    ] with-callback py-list-call ;

: always-33-fun ( -- alien )
    [ 3drop 33 >py ] PyCallback ;

{ V{ 33 33 } } [ always-33-fun py-map-call ] py-test

: id-fun ( -- alien )
    [ drop nip py> first >py ] PyCallback ;

{ V{ 1 2 } } [ id-fun py-map-call ] py-test
