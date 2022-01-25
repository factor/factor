USING: accessors arrays assocs continuations destructors destructors.private
fry io.files.temp kernel math namespaces python python.ffi
python.modules.builtins python.modules.argparse python.modules.datetime
python.modules.os python.modules.os.path python.modules.sys
python.modules.time python.objects python.syntax sets splitting tools.test
unicode ;
QUALIFIED-WITH: sequences s
IN: python.syntax.tests

: py-test ( result quot -- )
    '[ python-dll-loaded? [ _ [ _ with-destructors ] unit-test ] when ] call ; inline

: long-py-test ( result quot -- )
    '[ python-dll-loaded? [ _ [ _ with-destructors ] long-unit-test ] when ] call ; inline

{ t } [ getpid py> integer? ] py-test

! Automatic tuple unpacking
[ "hello.doc" ] [ "/some/path/hello.doc" >py basename py> ] py-test

[ { "hello" ".doc" } ] [
    "hello.doc" >py splitext [ py> ] bi@ 2array
] py-test

[ ] [ 0 >py sleep ] py-test

! Module variables are bound as zero-arg functions
{ t } [ $path py> s:sequence? ] py-test

{ t } [ $path py> s:empty? not ] py-test

[ 10 ] [ 10 >py range len py> ] py-test

! Callables
{ t } [
    "os" py-import "getpid" getattr
    [ callable ] [ PyCallable_Check 1 = ] bi and
] py-test

! Reference counting
{ 1 } [ 3 <py-tuple> getrefcount py> ] py-test

{ -1 } [
    H{ { "foo" 33 } { "bar" 44 } } >py
    [ "foo" py-dict-get-item-string getrefcount py> ]
    [
        '[
            500 [ _ "foo" py-dict-get-item-string drop ] times
        ] with-destructors
    ]
    [ "foo" py-dict-get-item-string getrefcount py> ] tri -
] py-test

{ -1 } [
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
    [ always-destructors get [ alien>> = ] with s:count ] bi =
] py-test

{ t } [
    "python-file" temp-file >py "wb" >py open
    [ tell ] [ fileno ] [ close ] tri
    [ py> integer? ] both?
] py-test

! Method chaining
{ t } [
    "hello there" >py title 20 >py zfill "00" >py startswith py>
] py-test

[ { "hello" "=" "there" } ] [
    "hello=there" >py "=" >py partition [ py> ] tri@ 3array
] py-test

! Introspection
PY-METHODS: func =>
    __code__ ( func -- code ) ;

PY-METHODS: code =>
    co_argcount ( code -- n ) ;

{ 1 } [ $splitext $__code__ $co_argcount py> ] py-test

! Change sys.path
{ t } [
    $path "test" >py [ append ] [ drop py> ] [ remove ] 2tri
    "test" swap in?
] py-test

! Support for kwargs
[ "datetime.timedelta(days=4, seconds=10800)" ] [
    H{ { "hours" 99 } } >py timedelta repr py>
] py-test

! Kwargs in methods
{ t } [
    [
        ArgumentParser dup
        "--foo" >py H{ { "help" "badger" } } >py add_argument
        format_help py>
    ] with-destructors [ blank? ] s:trim split-words "badger" swap in?
] py-test

{ t } [
    [ 987 >py basename ] [ ] recover python-error?
] py-test

! Test if exceptions leak references. If so, the test will leak a few
! hundred megs of memory. Enough to be noticed but not to slow down
! the tests too much.
{ } [
    100000 [
        [ [ 987 >py basename drop ] ignore-errors ] with-destructors
    ] times
] long-py-test

! Another leaky test
{ } [
    1000000 [
        [ { 9 8 7 6 5 4 3 2 1 } >py ] with-destructors drop
    ] times
] long-py-test

! Make callbacks
PY-QUALIFIED-FROM: builtins =>
    map ( func iter -- iter' )
    list ( iter -- seq ) ;

PY-QUALIFIED-FROM: functools =>
    reduce ( func iter -- iter' ) ;

: double-fun ( -- alien )
    [ drop s:first 2 * ] quot>py-callback ;

{ V{ 2 4 16 2 4 68 } } [
    double-fun [
        { 1 2 8 1 2 34 } >py builtins:map builtins:list py>
    ] with-quot>py-cfunction
] py-test

: reduce-func ( -- alien )
    [ drop s:first2 + ] quot>py-callback ;

{ 48 } [
    reduce-func [
        { 1 2 8 1 2 34 } >py functools:reduce py>
    ] with-quot>py-cfunction
] py-test
