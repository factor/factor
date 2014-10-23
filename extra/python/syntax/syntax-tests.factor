USING: accessors arrays assocs continuations destructors destructors.private
fry io.files.temp kernel math namespaces python python.ffi python.objects
python.syntax sequences sets splitting tools.test unicode.categories ;
IN: python.syntax.tests

: py-test ( result quot -- )
    '[ _ with-destructors ] unit-test ; inline

! py-importing functions
PY-FROM: os =>
    getpid ( -- y )
    system ( x -- y ) ;

[ t ] [ getpid py> integer? ] unit-test

! Automatic tuple unpacking
PY-FROM: os.path =>
    basename ( x -- x' )
    splitext ( x -- base ext ) ;

[ "hello.doc" ] [ "/some/path/hello.doc" >py basename py> ] unit-test

[ { "hello" ".doc" } ] [
    "hello.doc" >py splitext 2array [ py> ] map
] unit-test

PY-FROM: time => sleep ( n -- ) ;

[ ] [ 0 >py sleep ] unit-test

! Module variables are bound as zero-arg functions
PY-FROM: sys => path ( -- seq ) argv ( -- seq ) ;

[ t ] [ $path py> sequence? ] unit-test

PY-FROM: __builtin__ =>
    callable ( obj -- ? )
    dir ( obj -- seq )
    int ( val -- s )
    len ( seq -- n )
    open ( name mode -- file )
    range ( n -- seq )
    repr ( obj -- str ) ;

[ t ] [ $path len int py> 5 > ] unit-test

[ 10 ] [ 10 >py range len py> ] unit-test

! Callables
[ t ] [
    "os" py-import "getpid" getattr
    [ callable ] [ PyCallable_Check 1 = ] bi and
] unit-test

! Reference counting
PY-FROM: sys => getrefcount ( obj -- n ) ;

[ 2 ] [ 3 <py-tuple> getrefcount py> ] unit-test

[ -2 ] [
    H{ { "foo" 33 } { "bar" 44 } } >py
    [ "foo" py-dict-get-item-string getrefcount py> ]
    [
        '[
            500 [ _ "foo" py-dict-get-item-string drop ] times
        ] with-destructors
    ]
    [ "foo" py-dict-get-item-string getrefcount py> ] tri -
] py-test

[ -2 ] [
    "abcd" >py <1py-tuple>
    [ 0 py-tuple-get-item getrefcount py> ]
    [
        [ 100 [ swap 0 py-tuple-get-item drop ] with times ] with-destructors
    ]
    [ 0 py-tuple-get-item getrefcount py> ] tri -
] py-test

{ t } [
    6 <py-tuple>
    [ getrefcount py> 1 - ]
    [ always-destructors get [ alien>> = ] with count ] bi =
] py-test



PY-METHODS: file =>
    close ( self -- )
    fileno ( self -- n )
    tell ( self -- n ) ;

[ t ] [
    "python-file" temp-file >py "wb" >py open
    [ tell ] [ fileno ] [ close ] tri
    [ py> integer? ] bi@ and
] py-test

PY-METHODS: str =>
    lower ( self -- self' )
    partition ( self sep -- bef sep aft )
    startswith ( self str -- ? )
    title ( self -- self' )
    zfill ( self n -- str' ) ;

! Method chaining
[ t ] [
    "hello there" >py title 20 >py zfill "00" >py startswith py>
] py-test

[ { "hello" "=" "there" } ] [
    "hello=there" >py "=" >py partition 3array [ py> ] map
] py-test

! Introspection
PY-METHODS: func =>
    func_code ( func -- code ) ;

PY-METHODS: code =>
    co_argcount ( code -- n ) ;

[ 1 ] [ $splitext $func_code $co_argcount py> ] py-test

! Change sys.path
PY-METHODS: list =>
    append ( list obj -- )
    remove ( list obj -- ) ;

[ t ] [
    $path "test" >py [ append ] [ drop py> ] [ remove ] 2tri
    "test" swap in?
] py-test

! setattr doesn't affect which objects $words are referencing.
PY-FROM: sys => platform ( -- x ) ;

[ t ] [
    $platform "sys" py-import "platform" "tjaba" >py setattr $platform =
] py-test

! Support for kwargs
PY-FROM: datetime => timedelta ( ** -- timedelta ) ;

[ "datetime.timedelta(4, 10800)" ] [
    H{ { "hours" 99 } } >py timedelta repr py>
] py-test

! Kwargs in methods
PY-FROM: argparse => ArgumentParser ( -- self ) ;
PY-METHODS: ArgumentParser =>
    add_argument ( self name ** -- )
    format_help ( self -- str ) ;

[ t ] [
    [
        ArgumentParser dup
        "--foo" >py H{ { "help" "badger" } } >py add_argument
        format_help py>
    ] with-destructors [ blank? ] trim " " split "badger" swap in?
] py-test

! Can you pass a callback written in factor to a python function?
PY-FROM: wsgiref.simple_server => make_server ( iface port callback -- httpd ) ;

{ t } [
    [ 987 >py basename ] [ traceback>> ] recover length 0 >
] unit-test

! Test if exceptions leak references. If so, the test will leak a few
! hundred megs of memory. Enough to be noticed but not to slow down
! the tests too much.
{ } [
    100000 [
        [ [ 987 >py basename drop ] ignore-errors ] with-destructors
    ] times
] unit-test

! Another leaky test
{ } [
    1000000 [
        [ { 9 8 7 6 5 4 3 2 1 } >py ] with-destructors drop
    ] times
] unit-test


! Working with types
PY-METHODS: obj =>
    __name__ ( self -- n ) ;

PY-QUALIFIED-FROM: types => UnicodeType ( -- ) ;

{ "unicode" } [
    types:$UnicodeType $__name__ py>
] py-test

! Make callbacks

PY-QUALIFIED-FROM: __builtin__ =>
    None ( -- )
    map ( func seq -- seq' )
    reduce ( func seq -- seq' ) ;

{ V{ 1 2 3 } } [
    __builtin__:$None { 1 2 3 } >py __builtin__:map py>
] py-test

: double-fun ( -- alien )
    [ drop first 2 * ] quot>py-callback ;

{ V{ 2 4 16 2 4 68 } } [
    double-fun [ { 1 2 8 1 2 34 } >py __builtin__:map py> ] with-quot>py-cfunction
] py-test

: reduce-func ( -- alien )
    [ drop first2 + ] quot>py-callback ;

{ 48 } [
    reduce-func [
        { 1 2 8 1 2 34 } >py __builtin__:reduce py>
    ] with-quot>py-cfunction
] py-test
