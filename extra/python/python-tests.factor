USING: accessors arrays assocs calendar continuations destructors fry kernel
math namespaces python python.ffi python.objects sequences strings tools.test ;
IN: python.tests

py-initialize

: py-test ( result quot -- )
    '[ _ with-destructors ] unit-test ; inline

[ t ] [ Py_GetVersion string? ] unit-test

[ "os" ] [ "os" import PyModule_GetName ] py-test

[ t ] [
    "os" import "getpid" getattr
    { } >py call-object >factor 0 >
] py-test

[ t ] [ Py_IsInitialized ] py-test

! Importing
[ { "ImportError" "No module named kolobi" } ] [
    [ "kolobi" import ] [ [ type>> ] [ message>> ] bi 2array ] recover
] py-test

! setattr
[ 73 ] [
    "sys" import "testit" [ 73 >py setattr ] [ getattr >factor ] 2bi
] py-test

! Tuples
[ 2 ] [ 2 <py-tuple> py-tuple-size ] py-test

: py-date>factor ( py-obj -- timestamp )
    { "year" "month" "day" } [ getattr >factor ] with map
    first3 0 0 0 instant <timestamp> ;

! Lists
[ t ] [ V{ 4 8 15 16 23 42 } dup >py >factor = ] py-test

! ! Datetimes
[ t ] [
    [ py-date>factor ] "date" py-type-dispatch get set-at
    "datetime" import "date" getattr "today" getattr
    { } >py call-object >factor
    today instant >>gmt-offset =
] py-test

! Unicode
[ "غثههح" ] [
    "os.path" import "basename" getattr { "غثههح" } >py call-object >factor
] py-test

! Instance variables
[ 7 ] [
    "datetime" import "timedelta" getattr
    { 7 } >py call-object "days" getattr >factor
] py-test

! Create a dictonary
[ 0 ] [ <py-dict> py-dict-size ] py-test

! Dictionary with object keys
[ 1 ] [
    <py-dict> dup 0 >py 33 >py py-dict-set-item py-dict-size
] py-test

! Dictionary with string keys
[ 1 ] [
    <py-dict> [ "foo" 33 >py py-dict-set-item-string ] [ py-dict-size ] bi
] py-test

! Get dictionary items
[ 33 ] [
    <py-dict> "tjaba"
    [ 33 >py  py-dict-set-item-string ]
    [ py-dict-get-item-string >factor ] 2bi
] py-test

! Nest dicts
[ 0 ] [
    <py-dict> "foo"
    [ <py-dict> py-dict-set-item-string ]
    [ py-dict-get-item-string ] 2bi
    py-dict-size
] py-test

! Nested tuples
[ 3 ] [
    1 <py-tuple> dup 0 3 <py-tuple> py-tuple-set-item
    0 py-tuple-get-item py-tuple-size
] py-test

! Round tripping!
[ { "foo" { 99 77 } } ] [ { "foo" { 99 77 } } >py >factor ] py-test

[ H{ { "foo" "bar" } { 3 4 } } ] [
    H{ { "foo" "bar" } { 3 4 } } >py >factor
] py-test

! Kwargs
[ 2014 10 22 ] [
    "datetime" import "date" getattr
    { } >py H{ { "year" 2014 } { "month" 10 } { "day" 22 } } >py
    call-object-full >factor
    [ year>> ] [ month>> ] [ day>> ] tri
] py-test

! Modules
[ t ] [
    "os" import PyModule_GetDict dup Py_IncRef &Py_DecRef py-dict-size 100 >
] py-test
