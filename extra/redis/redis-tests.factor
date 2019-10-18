! Copyright (C) 2014 Benjamin Pollack
! See http://factorcode.org/license.txt for BSD license

USING: continuations kernel redis math math.parser sequences
sorting tools.test ;

IN: redis.tests

: with-redis ( quot -- )
    [ redis-flushdb ] prepose
    <redis> swap redis:with-redis ; inline

{ -1 } [ [ "foo" redis-decr ] with-redis ] unit-test

{ 1 } [ [ "foo" redis-incr ] with-redis ] unit-test

{ -2 } [
    [ 2 "foo" redis-decrby ] with-redis
] unit-test

{ 2 } [ [ 2 "foo" redis-incrby ] with-redis ] unit-test

{ "hello" } [
    [
        "hello" "foo" redis-set
        "foo" redis-get
    ] with-redis
] unit-test

{ { "aa" "ab" "ac" } } [
    [
        { "aa" "ab" "ac" "bd" } [ "hello" swap redis-set ] each
        "a*" redis-keys natural-sort
    ] with-redis
] unit-test

{ "hello" } [
    [
        "world" "hello" redis-set redis-randomkey
    ] with-redis
] unit-test

{ { "3" "2" "1" } "1" "5" "3" } [
    [
        { 1 2 3 } [
            number>string "list" redis-lpush drop
        ] each
        0 -1 "list" redis-lrange
        "5" 1 "list" redis-lset
        3 [ "list" redis-rpop ] times
    ] with-redis
] unit-test

{ { "world" } "1" 2 } [
    [
        "1" "world" "hello" redis-hset drop
        "hello" redis-hkeys
        "world" "hello" redis-hget
        1 "world" "hello" redis-hincrby
    ] with-redis
] unit-test

{ t } [
    [
        "world" "hello" redis-set
        [ "hello" redis-incr ] [ drop t ] recover
    ] with-redis
] unit-test
