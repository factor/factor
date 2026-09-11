! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences strings tools.test unix.groups ;
IN: unix.groups.tests

[ all-groups ] must-not-fail

{ t } [ real-group-name string? ] unit-test
{ t } [ effective-group-name string? ] unit-test

{ t } [ real-group-id integer? ] unit-test
{ t } [ effective-group-id integer? ] unit-test

{ } [ real-group-id set-real-group ] unit-test
{ } [ effective-group-id set-effective-group ] unit-test

{ } [ real-group-name [ ] with-real-group ] unit-test
{ } [ real-group-id [ ] with-real-group ] unit-test

{ } [ effective-group-name [ ] with-effective-group ] unit-test
{ } [ effective-group-id [ ] with-effective-group ] unit-test

{ } [ [ ] with-group-cache ] unit-test

[ real-group-id group-name ] must-not-fail

{ "888888888888888" } [ 888888888888888 group-name ] unit-test
{ f } [ "please-oh-please-don't-have-a-group-named-this123lalala" group-struct ] unit-test
{ f } [ "please-oh-please-don't-have-a-group-named-this123lalala" group-exists? ] unit-test
[ "please-oh-please-don't-have-a-group-named-this123lalala" ?group-id ] must-fail

{ 3 } [ f [ 3 ] with-effective-group ] unit-test
{ 3 } [ f [ 3 ] with-real-group ] unit-test

{ f }
[ all-groups drop all-groups empty? ] unit-test

{ f }
[ all-group-names drop all-group-names empty? ] unit-test

{ f }
[ "root" user-groups empty? ] unit-test

{ t }
[ "29032039029302930290390329uafjklajsdfkasjflaskjflsadkjfroot" user-groups empty? ] unit-test

USING: accessors alien.accessors alien.c-types alien.data combinators continuations
destructors libc locals memory namespaces sets tools.annotations unix.ffi
unix.groups.private unix.types ;
QUALIFIED: unix.ffi

TUPLE: group-probe calls mode ;
SYMBOL: current-group-probe

:: injected-group-lookup ( key entry buffer size result original -- status )
    current-group-probe get [ 1 + ] change-calls :> probe
    probe mode>> {
        { "error" [ EIO ] }
        { "interrupt" [ probe calls>> 1 = EINTR f ? ] }
        { "grow" [ size 8192 < ERANGE f ? ] }
    } case :> forced
    forced [ forced ] [
        key entry buffer size result
        original call( key entry buffer size result -- status )
    ] if ; inline

:: with-group-fault ( word mode quot: ( -- obj ) -- obj calls )
    0 mode group-probe boa current-group-probe [
        [
            word [ [ injected-group-lookup ] curry ] annotate
            quot call current-group-probe get calls>>
        ] [ word reset ] finally
    ] with-variable ; inline

{ t 1 } [
    \ unix.ffi:getgrgid_r "error" [
        [ real-group-id group-name drop f ] [ errno>> EIO = ] recover
    ] with-group-fault
] unit-test

! Enumeration owns libc's group database handle even if copying an entry fails.
SYMBOL: enumeration-ended?

{ t } [
    f enumeration-ended? [
        [
            \ group-struct>group [ drop [ drop "group-copy-failed" throw ] ] annotate
            \ unix.ffi:endgrent
            [ [ t enumeration-ended? set ] compose ] annotate
            [ all-groups ] [ "group-copy-failed" = ] must-fail-with
            enumeration-ended? get
        ] [
            \ group-struct>group reset
            \ unix.ffi:endgrent reset
        ] finally
    ] with-variable
] unit-test

{ t 2 } [
    \ unix.ffi:getgrgid_r "interrupt" [ real-group-id group-name string? ]
    with-group-fault
] unit-test

{ t 2 } [
    \ unix.ffi:getgrnam_r "grow" [ real-group-name group-id integer? ]
    with-group-fault
] unit-test

! Native lookup buffers must be released even when lookup fails.
{ t } [
    disposables get cardinality
    \ unix.ffi:getgrnam_r "error" [
        [ "root" group-id drop f ] [ errno>> EIO = ] recover
    ] with-group-fault 1 assert= t assert=
    disposables get cardinality =
] unit-test

! A returned entry owns its strings, including after its buffer is released.
{ t t } [
    real-group-id group-struct
    compact-gc
    [ id>> real-group-id = ] [ name>> real-group-name = ] bi
] unit-test

:: many-groups ( name gid buffer count -- status )
    name drop
    count int deref 65 < [
        65 count 0 int set-alien-value clear-errno -1
    ] [
        65 [| i | gid buffer i gid_t heap-size * set-alien-unsigned-4 ] each-integer
        65 count 0 int set-alien-value 65
    ] if ;

{ 65 } [
    [
        \ unix.ffi:getgrouplist [ drop [ many-groups ] ] annotate
        "root" user-groups length
    ] [ \ unix.ffi:getgrouplist reset ] finally
] unit-test
