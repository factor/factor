! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test redis.command-writer io.streams.string ;
IN: redis.command-writer.tests

#! Connection
[ "QUIT\r\n" ] [ [ quit ] with-string-writer ] unit-test

[ "PING\r\n" ] [ [ ping ] with-string-writer ] unit-test

[ "AUTH password\r\n" ] [ [ "password" auth ] with-string-writer ] unit-test

#! String values
[ "SET key 3\r\nfoo\r\n" ] [ [ "foo" "key" set ] with-string-writer ] unit-test

[ "GET key\r\n" ] [ [ "key" get ] with-string-writer ] unit-test

[ "GETSET key 3\r\nfoo\r\n" ] [
    [ "foo" "key" getset ] with-string-writer
] unit-test

[ "MGET key1 key2 key3\r\n" ] [
    [ { "key1" "key2" "key3" } mget ] with-string-writer
] unit-test

[ "SETNX key 3\r\nfoo\r\n" ] [
    [ "foo" "key" setnx ] with-string-writer
] unit-test

[ "INCR key\r\n" ] [ [ "key" incr ] with-string-writer ] unit-test

[ "INCRBY key 7\r\n" ] [ [ 7 "key" incrby ] with-string-writer ] unit-test

[ "DECR key\r\n" ] [ [ "key" decr ] with-string-writer ] unit-test

[ "DECRBY key 7\r\n" ] [ [ 7 "key" decrby ] with-string-writer ] unit-test

[ "EXISTS key\r\n" ] [ [ "key" exists ] with-string-writer ] unit-test

[ "DEL key\r\n" ] [ [ "key" del ] with-string-writer ] unit-test

[ "TYPE key\r\n" ] [ [ "key" type ] with-string-writer ] unit-test

#! Key space
[ "KEYS pat*\r\n" ] [ [ "pat*" keys ] with-string-writer ] unit-test

[ "RANDOMKEY\r\n" ] [ [ randomkey ] with-string-writer ] unit-test

[ "RENAME key newkey\r\n" ] [
    [ "newkey" "key" rename ] with-string-writer
] unit-test

[ "RENAMENX key newkey\r\n" ] [
    [ "newkey" "key" renamenx ] with-string-writer
] unit-test

[ "DBSIZE\r\n" ] [ [ dbsize ] with-string-writer ] unit-test

[ "EXPIRE key 7\r\n" ] [ [ 7 "key" expire ] with-string-writer ] unit-test

#! Lists
[ "RPUSH key 3\r\nfoo\r\n" ] [ [ "foo" "key" rpush ] with-string-writer ] unit-test

[ "LPUSH key 3\r\nfoo\r\n" ] [ [ "foo" "key" lpush ] with-string-writer ] unit-test

[ "LLEN key\r\n" ] [ [ "key" llen ] with-string-writer ] unit-test

[ "LRANGE key 5 9\r\n" ] [ [ 5 9 "key" lrange ] with-string-writer ] unit-test

[ "LTRIM key 5 9\r\n" ] [ [ 5 9 "key" ltrim ] with-string-writer ] unit-test

[ "LINDEX key 7\r\n" ] [ [ 7 "key" lindex ] with-string-writer ] unit-test

[ "LSET key 0 3\r\nfoo\r\n" ] [ [ "foo" 0 "key" lset ] with-string-writer ] unit-test

[ "LREM key 1 3\r\nfoo\r\n" ] [ [ "foo" 1 "key" lrem ] with-string-writer ] unit-test

[ "LPOP key\r\n" ] [ [ "key" lpop ] with-string-writer ] unit-test

[ "RPOP key\r\n" ] [ [ "key" rpop ] with-string-writer ] unit-test

#! Sets
[ "SADD key 3\r\nfoo\r\n" ] [ [ "foo" "key" sadd ] with-string-writer ] unit-test

[ "SREM key 3\r\nfoo\r\n" ] [ [ "foo" "key" srem ] with-string-writer ] unit-test

[ "SMOVE srckey dstkey 3\r\nfoo\r\n" ] [
    [ "foo" "dstkey" "srckey" smove ] with-string-writer
] unit-test

[ "SCARD key\r\n" ] [ [ "key" scard ] with-string-writer ] unit-test

[ "SISMEMBER key 3\r\nfoo\r\n" ] [
    [ "foo" "key" sismember ] with-string-writer
] unit-test

[ "SINTER key1 key2 key3\r\n" ] [
    [ { "key1" "key2" "key3" } sinter ] with-string-writer
] unit-test

[ "SINTERSTORE dstkey key1 key2 key3\r\n" ] [
    [ { "key1" "key2" "key3" } "dstkey" sinterstore ] with-string-writer
] unit-test

[ "SUNION key1 key2 key3\r\n" ] [
    [ { "key1" "key2" "key3" } sunion ] with-string-writer
] unit-test

[ "SUNIONSTORE dstkey key1 key2 key3\r\n" ] [
    [ { "key1" "key2" "key3" } "dstkey" sunionstore ] with-string-writer
] unit-test

[ "SMEMBERS key\r\n" ] [ [ "key" smembers ] with-string-writer ] unit-test

#! Multiple db
[ "SELECT 2\r\n" ] [ [ 2 select ] with-string-writer ] unit-test

[ "MOVE key 2\r\n" ] [ [ 2 "key" move ] with-string-writer ] unit-test

[ "FLUSHDB\r\n" ] [ [ flushdb ] with-string-writer ] unit-test

[ "FLUSHALL\r\n" ] [ [ flushall ] with-string-writer ] unit-test

#! Sorting

#! Persistence control
[ "SAVE\r\n" ] [ [ save ] with-string-writer ] unit-test

[ "BGSAVE\r\n" ] [ [ bgsave ] with-string-writer ] unit-test

[ "LASTSAVE\r\n" ] [ [ lastsave ] with-string-writer ] unit-test

[ "SHUTDOWN\r\n" ] [ [ shutdown ] with-string-writer ] unit-test

#! Remote server control
[ "INFO\r\n" ] [ [ info ] with-string-writer ] unit-test

[ "MONITOR\r\n" ] [ [ monitor ] with-string-writer ] unit-test
