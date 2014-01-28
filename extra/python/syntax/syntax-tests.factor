USING: assocs destructors fry kernel math namespaces python python.ffi
python.syntax python.tests sequences tools.test ;
IN: python.syntax.tests

! Define your own type conversions.
[ py-date>factor ] "date" py-type-dispatch get set-at

! Importing functions
PY-FROM: os =>
    getpid ( -- y )
    system ( x -- y ) ;

[ t ] [ getpid integer? ] unit-test

! Automatic tuple unpacking
PY-FROM: os.path =>
    basename ( x -- x' )
    splitext ( x -- base ext ) ;

[ "hello.doc" ] [ "/some/path/hello.doc" basename ] unit-test

[ "hello" ".doc" ] [ "hello.doc" splitext ] unit-test

PY-FROM: time => sleep ( n -- ) ;

[ ] [ 0 sleep ] unit-test

! Module variables are bound as zero-arg functions
PY-FROM: sys => path ( -- seq ) ;

[ t ] [ path sequence? ] unit-test

! Use the pipe functions to work on PyObjects.
PY-FROM: __builtin__ =>
    callable ( obj -- ? )
    int ( val -- s )
    len ( seq -- n )
    range ( n -- seq ) ;

[ t ] [ path| |len| |int 5 > ] unit-test

[ 10 ] [ 10 range| |len ] py-test

! Callables
[ t ] [
    "os" import "getpid" getattr
    [ |callable ] [ PyCallable_Check 1 = ] bi and
] py-test

! Reference counting
PY-FROM: sys => getrefcount ( obj -- n ) ;

[ 2 ] [ 3 <py-tuple> |getrefcount ] py-test

[ -2 ] [
    H{ { "foo" 33 } { "bar" 44 } } >py
    [ "foo" py-dict-get-item-string |getrefcount ]
    [
        '[
            500 [ _ "foo" py-dict-get-item-string drop ] times
        ] with-destructors
    ]
    [ "foo" py-dict-get-item-string |getrefcount ] tri -
] py-test

[ -2 ] [
    "abcd" >py <1py-tuple>
    [ 0 py-tuple-get-item |getrefcount ]
    [
        [ 100 [ swap 0 py-tuple-get-item drop ] with times ] with-destructors
    ]
    [ 0 py-tuple-get-item |getrefcount ] tri -
] py-test
