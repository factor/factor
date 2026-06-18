! Copyright (C) 2014 Benjamin Pollack
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays continuations kernel math math.parser redis
redis.response-parser sequences sorting tools.test ;

IN: redis.tests

! These tests require a Redis server listening on 127.0.0.1:6379.
! Every command word takes a sequence of arguments in Redis' natural
! order and returns the parsed reply.

: with-redis-test ( quot -- )
    [ { } redis-flushdb drop ] prepose
    <redis> swap with-redis ; inline

{ -1 } [ [ { "foo" } redis-decr ] with-redis-test ] unit-test

{ 1 } [ [ { "foo" } redis-incr ] with-redis-test ] unit-test

{ -2 } [ [ { "foo" 2 } redis-decrby ] with-redis-test ] unit-test

{ 2 } [ [ { "foo" 2 } redis-incrby ] with-redis-test ] unit-test

{ "hello" } [
    [
        { "foo" "hello" } redis-set drop
        { "foo" } redis-get
    ] with-redis-test
] unit-test

{ { "aa" "ab" "ac" } } [
    [
        { "aa" "ab" "ac" "bd" } [ "hello" 2array redis-set drop ] each
        { "a*" } redis-keys sort
    ] with-redis-test
] unit-test

{ "hello" } [
    [
        { "hello" "world" } redis-set drop
        { } redis-randomkey
    ] with-redis-test
] unit-test

{ { "3" "2" "1" } "1" "5" "3" } [
    [
        { 1 2 3 } [ number>string "list" swap 2array redis-lpush drop ] each
        { "list" 0 -1 } redis-lrange
        { "list" 1 "5" } redis-lset drop
        3 [ { "list" } redis-rpop ] times
    ] with-redis-test
] unit-test

{ { "world" } "1" 2 } [
    [
        { "hello" "world" "1" } redis-hset drop
        { "hello" } redis-hkeys
        { "hello" "world" } redis-hget
        { "hello" "world" 1 } redis-hincrby
    ] with-redis-test
] unit-test

{ t } [
    [
        { "hello" "world" } redis-set drop
        [ { "hello" } redis-incr ] [ drop t ] recover
    ] with-redis-test
] unit-test

! generic sender + simple-string reply
{ "PONG" } [ [ { "PING" } redis-send message>> ] with-redis-test ] unit-test

! Scripting
{ "e0e1f9fabfc9d4800c877a703b823ac0578ff8db" } [
    [ { "return 1" } redis-script-load ] with-redis-test
] unit-test

{ { 0 0 } } [
    [ { "foo" "bar" } redis-script-exists ] with-redis-test
] unit-test

{ } [ [ { } redis-script-flush drop ] with-redis-test ] unit-test

{ { "foo" } } [
    [ { "return { ARGV[1] }" 0 "foo" } redis-eval ] with-redis-test
] unit-test

! RESP3: negotiate protocol 3, HGETALL returns a map (alist)
{ { { "field" "value" } } } [
    <redis> 3 >>protocol [
        { } redis-flushdb drop
        { "h" "field" "value" } redis-hset drop
        { "h" } redis-hgetall
    ] with-redis
] unit-test

! Multibyte values round-trip without desyncing the connection
{ "héllo" } [
    [ { "k" "héllo" } redis-set drop { "k" } redis-get ] with-redis-test
] unit-test

! A failing command inside MULTI/EXEC is returned as an error value in
! the EXEC array rather than throwing and desyncing the connection
{ t } [
    [
        { "MULTI" } redis-send drop
        { "k" "v" } redis-set drop      ! QUEUED
        { "k" } redis-incr drop         ! QUEUED, fails at EXEC (not an int)
        { "EXEC" } redis-send second redis-error?
    ] with-redis-test
] unit-test
