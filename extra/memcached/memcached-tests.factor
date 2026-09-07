! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs calendar continuations hashtables io io.encodings.ascii
io.encodings.binary io.files io.files.info io.launcher io.pathnames
io.sockets io.timeouts kernel locals math math.functions math.parser
memcached memcached.private namespaces present sequences sorting
splitting system system-info threads tools.test ;

IN: memcached.tests

! Use a version of with-memcached that sets a timeout
: with-memcached ( quot -- )
    [ 5 seconds input-stream get set-timeout ] prepose
    memcached:with-memcached ; inline

<PRIVATE

: not-found? ( quot -- )
    [ key-not-found? ] must-fail-with ;

: x ( -- str ) os cpu [ present ] bi@ "-" glue "-x" append ;
: y ( -- str ) os cpu [ present ] bi@ "-" glue "-y" append ;
: z ( -- str ) os cpu [ present ] bi@ "-" glue "-z" append ;

PRIVATE>

! Flush commands affect every key, so a prefix cannot isolate these tests.
! Have memcached choose an unused TCP port and publish it in a private file.
:: wait-for-test ( predicate: ( -- ? ) -- )
    nano-count 10,000,000,000 + :> deadline
    predicate [
        nano-count deadline > [ "Timed out waiting for test memcached" throw ] when
        10 milliseconds sleep
    ] until ; inline

:: with-test-memcached ( quot: ( -- ) -- )
    [
        "ports" absolute-path :> port-file
        <process>
            { "memcached" "-l" "127.0.0.1" "-p" "-1" "-U" "0" "-t" "1" "-u" }
            username suffix >>command
            port-file "MEMCACHED_PORT_FILENAME" associate >>environment
            +closed+ >>stdin
            run-detached :> server
        [
            [
                server process-running? [ server wait-for-success ] unless
                port-file file-exists?
            ] wait-for-test
            port-file ascii file-lines
            [ "TCP INET: " head? ] find nip
            "TCP INET: " ?head drop string>number
            "127.0.0.1" swap <inet>
            memcached-server quot with-variable
        ] [
            server kill-process
            [ server wait-for-process ] [ process-was-killed? ] ignore-error/f drop
        ] finally
    ] with-test-directory ; inline

[

! An inner suite's flush must leave this suite's cache intact (#649).
{ "outer" } [
    [ "outer" "scope-sentinel" m/set ] with-memcached
    [ [ m/flush ] with-memcached ] with-test-memcached
    [ "scope-sentinel" m/get ] with-memcached
] unit-test

! test version
{ t } [ [ m/version ] with-memcached length 0 > ] unit-test

! test simple set get
[ m/flush ] with-memcached
[ "valuex" x m/set ] with-memcached
{ "valuex" } [ [ x m/get ] with-memcached ] unit-test

! test flush
[ m/flush ] with-memcached
[ "valuex" x m/set "valuey" y m/set ] with-memcached
{ "valuex" } [ [ x m/get ] with-memcached ] unit-test
{ "valuey" } [ [ y m/get ] with-memcached ] unit-test
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ [ y m/get ] with-memcached ] not-found?

! test noop
[ m/noop ] with-memcached

! test delete
[ m/flush ] with-memcached
[ "valuex" x m/set ] with-memcached
{ "valuex" } [ [ x m/get ] with-memcached ] unit-test
[ x m/delete ] with-memcached
[ [ x m/get ] with-memcached ] not-found?

! test replace
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ [ "ex" x m/replace ] with-memcached ] not-found?
[ "ex" x m/add ] with-memcached
{ "ex" } [ [ x m/get ] with-memcached ] unit-test
[ "ex2" x m/replace ] with-memcached
{ "ex2" } [ [ x m/get ] with-memcached ] unit-test

! test incr
[ m/flush ] with-memcached
{ 0 } [ [ x m/incr ] with-memcached ] unit-test
{ 1 } [ [ x m/incr ] with-memcached ] unit-test
{ 212 } [ [ 211 x m/incr-val ] with-memcached ] unit-test
{ 8589934804 } [ [ 2 33 ^ x m/incr-val ] with-memcached ] unit-test

! test decr
[ m/flush ] with-memcached
[ "5" x m/set ] with-memcached
{ 4 } [ [ x m/decr ] with-memcached ] unit-test
{ 0 } [ [ 211 x m/decr-val ] with-memcached ] unit-test

! test timebombed flush
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ "valuex" x m/set ] with-memcached
{ "valuex" } [ [ x m/get ] with-memcached ] unit-test
[ 2 m/flush-later ] with-memcached
! Scheduling can exceed the flush delay; wait for its observable result.
{ } [
    [
        [ [ x m/get ] with-memcached ] [ key-not-found? ] ignore-error/f not
    ] wait-for-test
] unit-test

! test append
[ m/flush ] with-memcached
[ "some" x m/set ] with-memcached
[ "thing" x m/append ] with-memcached
{ "something" } [ [ x m/get ] with-memcached ] unit-test

! test prepend
[ m/flush ] with-memcached
[ "some" x m/set ] with-memcached
[ "thing" x m/prepend ] with-memcached
{ "thingsome" } [ [ x m/get ] with-memcached ] unit-test

! test multi-get
[ m/flush ] with-memcached
{ H{ } } [ [ x y z 3array m/getseq ] with-memcached ] unit-test
[ "5" x m/set ] with-memcached
[ "valuex" y m/set ] with-memcached
{ { "5" "valuex" } } [
    [ x y z 3array m/getseq values sort ] with-memcached
] unit-test

] with-test-memcached
