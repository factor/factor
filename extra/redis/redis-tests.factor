! Copyright (C) 2014 Benjamin Pollack
! See https://factorcode.org/license.txt for BSD license

USING: continuations kernel redis math math.parser sequences
sorting tools.test ;

IN: redis.tests

: with-redis-test ( quot -- )
    [ redis-flushdb ] prepose
    <redis> swap with-redis ; inline

{ -1 } [ [ "foo" redis-decr ] with-redis-test ] unit-test

{ 1 } [ [ "foo" redis-incr ] with-redis-test ] unit-test

{ -2 } [
    [ 2 "foo" redis-decrby ] with-redis-test
] unit-test

{ 2 } [ [ 2 "foo" redis-incrby ] with-redis-test ] unit-test

{ "hello" } [
    [
        "hello" "foo" redis-set
        "foo" redis-get
    ] with-redis-test
] unit-test

{ { "aa" "ab" "ac" } } [
    [
        { "aa" "ab" "ac" "bd" } [ "hello" swap redis-set ] each
        "a*" redis-keys sort
    ] with-redis-test
] unit-test

{ "hello" } [
    [
        "world" "hello" redis-set redis-randomkey
    ] with-redis-test
] unit-test

{ { "3" "2" "1" } "1" "5" "3" } [
    [
        { 1 2 3 } [
            number>string "list" redis-lpush drop
        ] each
        0 -1 "list" redis-lrange
        "5" 1 "list" redis-lset
        3 [ "list" redis-rpop ] times
    ] with-redis-test
] unit-test

{ { "world" } "1" 2 } [
    [
        "1" "world" "hello" redis-hset drop
        "hello" redis-hkeys
        "world" "hello" redis-hget
        1 "world" "hello" redis-hincrby
    ] with-redis-test
] unit-test

{ t } [
    [
        "world" "hello" redis-set
        [ "hello" redis-incr ] [ drop t ] recover
    ] with-redis-test
] unit-test

{ "e0e1f9fabfc9d4800c877a703b823ac0578ff8db" } [
    [ "return 1" redis-script-load ] with-redis-test
] unit-test

{ { 0 0 } } [
    [ { "foo" "bar" } redis-script-exists ] with-redis-test
] unit-test

{ } [ [ redis-script-flush ] with-redis-test ] unit-test

{ { "foo" } } [
    [ "return { ARGV[1] }" { } { "foo" } redis-script-eval ] with-redis-test
] unit-test
