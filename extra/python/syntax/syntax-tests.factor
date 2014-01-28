USING: arrays assocs destructors fry kernel math namespaces python python.ffi
python.syntax python.tests sequences tools.test ;
IN: python.syntax.tests

! Importing functions
PY-FROM: os =>
    getpid ( -- y )
    system ( x -- y ) ;

[ t ] [ getpid >factor integer? ] unit-test

! ! Automatic tuple unpacking
PY-FROM: os.path =>
    basename ( x -- x' )
    splitext ( x -- base ext ) ;

[ "hello.doc" ] [ "/some/path/hello.doc" >py basename >factor ] unit-test

[ { "hello" ".doc" } ] [
    "hello.doc" >py splitext 2array [ >factor ] map
] unit-test

PY-FROM: time => sleep ( n -- ) ;

[ ] [ 0 >py sleep ] unit-test

! ! Module variables are bound as zero-arg functions
PY-FROM: sys => path ( -- seq ) ;

[ t ] [ path >factor sequence? ] unit-test

! ! Use the pipe functions to work on PyObjects.
PY-FROM: __builtin__ =>
    callable ( obj -- ? )
    open ( name mode -- file )
    int ( val -- s )
    len ( seq -- n )
    range ( n -- seq ) ;

[ t ] [ path len int >factor 5 > ] unit-test

[ 10 ] [ 10 >py range len >factor ] unit-test

! Callables
[ t ] [
    "os" import "getpid" getattr
    [ callable ] [ PyCallable_Check 1 = ] bi and
] unit-test

! Reference counting
PY-FROM: sys => getrefcount ( obj -- n ) ;

[ 2 ] [ 3 <py-tuple> getrefcount >factor ] unit-test

[ -2 ] [
    H{ { "foo" 33 } { "bar" 44 } } >py
    [ "foo" py-dict-get-item-string getrefcount >factor ]
    [
        '[
            500 [ _ "foo" py-dict-get-item-string drop ] times
        ] with-destructors
    ]
    [ "foo" py-dict-get-item-string getrefcount >factor ] tri -
] py-test

[ -2 ] [
    "abcd" >py <1py-tuple>
    [ 0 py-tuple-get-item getrefcount >factor ]
    [
        [ 100 [ swap 0 py-tuple-get-item drop ] with times ] with-destructors
    ]
    [ 0 py-tuple-get-item getrefcount >factor ] tri -
] py-test

PY-METHODS: file =>
    close ( self -- )
    fileno ( self -- n )
    tell ( self -- n ) ;

[ t ] [
    "testfile" >py "wb" >py open
    [ ->tell ] [ ->fileno ] [ ->close ] tri
    [ >factor integer? ] bi@ and
] py-test

PY-METHODS: str =>
    title ( self -- self' )
    startswith ( self str -- ? )
    zfill ( self n -- str' ) ;

! Method chaining
[ t ] [
    "hello there" >py ->title 20 >py ->zfill "00" >py ->startswith >factor
] py-test
