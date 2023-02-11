! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test redis.command-writer io.streams.string ;
IN: redis.command-writer.tests

! Connection
{ "*1\r\n$4\r\nQUIT\r\n" }
[ [ quit ] with-string-writer ] unit-test

{ "*1\r\n$4\r\nPING\r\n" }
[ [ ping ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nAUTH\r\n$8\r\npassword\r\n" }
[ [ "password" auth ] with-string-writer ] unit-test

! String values
{ "*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" set ] with-string-writer ] unit-test

{ "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n" }
[ [ "key" get ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nGETSET\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" getset ] with-string-writer ] unit-test

{ "*4\r\n$4\r\nMGET\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" }
[ [ { "key1" "key2" "key3" } mget ] with-string-writer ] unit-test

{ "*3\r\n$5\r\nSETNX\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" setnx ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nINCR\r\n$3\r\nkey\r\n" }
[ [ "key" incr ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nINCRBY\r\n$3\r\nkey\r\n$1\r\n7\r\n" }
[ [ 7 "key" incrby ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nDECR\r\n$3\r\nkey\r\n" }
[ [ "key" decr ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nDECRBY\r\n$3\r\nkey\r\n$1\r\n7\r\n" }
[ [ 7 "key" decrby ] with-string-writer ] unit-test

{ "*2\r\n$6\r\nEXISTS\r\n$3\r\nkey\r\n" }
[ [ "key" exists ] with-string-writer ] unit-test

{ "*2\r\n$3\r\nDEL\r\n$3\r\nkey\r\n" }
[ [ "key" del ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nTYPE\r\n$3\r\nkey\r\n" }
[ [ "key" type ] with-string-writer ] unit-test

! Key space
{ "*2\r\n$4\r\nKEYS\r\n$4\r\npat*\r\n" }
[ [ "pat*" keys ] with-string-writer ] unit-test

{ "*1\r\n$9\r\nRANDOMKEY\r\n" }
[ [ randomkey ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nRENAME\r\n$3\r\nkey\r\n$6\r\nnewkey\r\n" }
[
    [ "newkey" "key" rename ] with-string-writer
] unit-test

{ "*3\r\n$8\r\nRENAMENX\r\n$3\r\nkey\r\n$6\r\nnewkey\r\n" }
[
    [ "newkey" "key" renamenx ] with-string-writer
] unit-test

{ "*1\r\n$6\r\nDBSIZE\r\n" }
[ [ dbsize ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nEXPIRE\r\n$3\r\nkey\r\n$1\r\n7\r\n" }
[ [ 7 "key" expire ] with-string-writer ] unit-test

! Lists
{ "*3\r\n$5\r\nRPUSH\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" rpush ] with-string-writer ] unit-test

{ "*3\r\n$5\r\nLPUSH\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" lpush ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nLLEN\r\n$3\r\nkey\r\n" }
[ [ "key" llen ] with-string-writer ] unit-test

{ "*4\r\n$6\r\nLRANGE\r\n$3\r\nkey\r\n$1\r\n5\r\n$1\r\n9\r\n" }
[ [ 5 9 "key" lrange ] with-string-writer ] unit-test

{ "*4\r\n$5\r\nLTRIM\r\n$3\r\nkey\r\n$1\r\n5\r\n$1\r\n9\r\n" }
[ [ 5 9 "key" ltrim ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nLINDEX\r\n$3\r\nkey\r\n$1\r\n7\r\n" }
[ [ 7 "key" lindex ] with-string-writer ] unit-test

{ "*4\r\n$4\r\nLSET\r\n$3\r\nkey\r\n$1\r\n0\r\n$3\r\nfoo\r\n" }
[ [ "foo" 0 "key" lset ] with-string-writer ] unit-test

{ "*4\r\n$4\r\nLREM\r\n$3\r\nkey\r\n$1\r\n1\r\n$3\r\nfoo\r\n" }
[ [ "foo" 1 "key" lrem ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nLPOP\r\n$3\r\nkey\r\n" }
[ [ "key" lpop ] with-string-writer ] unit-test

{ "*2\r\n$4\r\nRPOP\r\n$3\r\nkey\r\n" }
[ [ "key" rpop ] with-string-writer ] unit-test

! Sets
{ "*3\r\n$4\r\nSADD\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" sadd ] with-string-writer ] unit-test

{ "*3\r\n$4\r\nSREM\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" srem ] with-string-writer ] unit-test

{ "*4\r\n$5\r\nSMOVE\r\n$6\r\nsrckey\r\n$6\r\ndstkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "dstkey" "srckey" smove ] with-string-writer ] unit-test

{ "*2\r\n$5\r\nSCARD\r\n$3\r\nkey\r\n" }
[ [ "key" scard ] with-string-writer ] unit-test

{ "*3\r\n$9\r\nSISMEMBER\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ "foo" "key" sismember ] with-string-writer ] unit-test

{ "*4\r\n$6\r\nSINTER\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" }
[ [ { "key1" "key2" "key3" } sinter ] with-string-writer ] unit-test

{ "*5\r\n$11\r\nSINTERSTORE\r\n$6\r\ndstkey\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" }
[
    [ { "key1" "key2" "key3" } "dstkey" sinterstore ] with-string-writer
] unit-test

{ "*4\r\n$6\r\nSUNION\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" }
[
    [ { "key1" "key2" "key3" } sunion ] with-string-writer
] unit-test

{ "*5\r\n$11\r\nSUNIONSTORE\r\n$6\r\ndstkey\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" } [
    [ { "key1" "key2" "key3" } "dstkey" sunionstore ] with-string-writer
] unit-test

{ "*2\r\n$8\r\nSMEMBERS\r\n$3\r\nkey\r\n" }
[ [ "key" smembers ] with-string-writer ] unit-test

! Hashes
{ "*3\r\n$4\r\nHDEL\r\n$3\r\nkey\r\n$5\r\nfield\r\n" }
[ [ "field" "key" hdel ] with-string-writer ] unit-test

{ "*3\r\n$7\r\nHEXISTS\r\n$3\r\nkey\r\n$5\r\nfield\r\n" }
[ [ "field" "key" hexists ] with-string-writer ] unit-test

{ "*3\r\n$4\r\nHGET\r\n$3\r\nkey\r\n$5\r\nfield\r\n" }
[ [ "field" "key" hget ] with-string-writer ] unit-test

{ "*2\r\n$7\r\nHGETALL\r\n$3\r\nkey\r\n" }
[ [ "key" hgetall ] with-string-writer ] unit-test

{ "*4\r\n$7\r\nHINCRBY\r\n$3\r\nkey\r\n$5\r\nfield\r\n$1\r\n1\r\n" }
[ [ 1 "field" "key" hincrby ] with-string-writer ] unit-test

{ "*4\r\n$12\r\nHINCRBYFLOAT\r\n$3\r\nkey\r\n$5\r\nfield\r\n$3\r\n1.0\r\n" }
[ [ 1.0 "field" "key" hincrbyfloat ] with-string-writer ] unit-test

{ "*2\r\n$5\r\nHKEYS\r\n$3\r\nkey\r\n" } [
    [ "key" hkeys ] with-string-writer
] unit-test

{ "*2\r\n$4\r\nHLEN\r\n$3\r\nkey\r\n" } [
    [ "key" hlen ] with-string-writer
] unit-test

{ "*4\r\n$5\r\nHMGET\r\n$3\r\nkey\r\n$6\r\nfield1\r\n$6\r\nfield2\r\n" }
[
    [
        { "field1" "field2" }
        "key"
        hmget
    ] with-string-writer
] unit-test

{ "*6\r\n$5\r\nHMSET\r\n$3\r\nkey\r\n$6\r\nfield1\r\n$6\r\nvalue1\r\n$6\r\nfield2\r\n$6\r\nvalue2\r\n" }
[
    [
        { { "field1" "value1" } { "field2" "value2" } }
        "key"
        hmset
    ] with-string-writer
] unit-test

{ "*4\r\n$4\r\nHSET\r\n$3\r\nkey\r\n$5\r\nfield\r\n$5\r\nvalue\r\n" }
[
    [
        "value"
        "field"
        "key"
        hset
    ] with-string-writer
] unit-test

{ "*4\r\n$6\r\nHSETNX\r\n$3\r\nkey\r\n$5\r\nfield\r\n$5\r\nvalue\r\n" }
[ [ "value" "field" "key" hsetnx ] with-string-writer ] unit-test

{ "*2\r\n$5\r\nHVALS\r\n$3\r\nkey\r\n" }
[ [ "key" hvals ] with-string-writer ] unit-test

! Multiple db
{ "*2\r\n$6\r\nSELECT\r\n$1\r\n2\r\n" }
[ [ 2 select ] with-string-writer ] unit-test

{ "*3\r\n$4\r\nMOVE\r\n$3\r\nkey\r\n$1\r\n2\r\n" }
[ [ 2 "key" move ] with-string-writer ] unit-test

{ "*1\r\n$7\r\nFLUSHDB\r\n" }
[ [ flushdb ] with-string-writer ] unit-test

{ "*1\r\n$8\r\nFLUSHALL\r\n" }
[ [ flushall ] with-string-writer ] unit-test

! Sorting

! Persistence control
{ "*1\r\n$4\r\nSAVE\r\n" } [ [ save ] with-string-writer ] unit-test

{ "*1\r\n$6\r\nBGSAVE\r\n" } [ [ bgsave ] with-string-writer ] unit-test

{ "*1\r\n$8\r\nLASTSAVE\r\n" } [ [ lastsave ] with-string-writer ] unit-test

{ "*1\r\n$8\r\nSHUTDOWN\r\n" } [ [ shutdown ] with-string-writer ] unit-test

! Remote server control
{ "*1\r\n$4\r\nINFO\r\n" } [ [ info ] with-string-writer ] unit-test

{ "*1\r\n$7\r\nMONITOR\r\n" } [ [ monitor ] with-string-writer ] unit-test

! Lua

{ "*3\r\n$6\r\nSCRIPT\r\n$4\r\nLOAD\r\n$8\r\nreturn 1\r\n" } [ [ "return 1" script-load ] with-string-writer ] unit-test

{ "*3\r\n$6\r\nSCRIPT\r\n$6\r\nEXISTS\r\n$9\r\nfake-hash\r\n" } [ [ { "fake-hash" } script-exists ] with-string-writer ] unit-test

{ "*2\r\n$6\r\nSCRIPT\r\n$5\r\nFLUSH\r\n" } [ [ script-flush ] with-string-writer ] unit-test

{ "*2\r\n$6\r\nSCRIPT\r\n$4\r\nKILL\r\n" } [ [ script-kill ] with-string-writer ] unit-test

{ "*6\r\n$4\r\nEVAL\r\n$36\r\nreturn { KEYS[1], KEYS[2], ARGV[1] }\r\n$1\r\n2\r\n$1\r\na\r\n$1\r\nb\r\n$3\r\n100\r\n" } [
    [ "return { KEYS[1], KEYS[2], ARGV[1] }" { "a" "b" } { 100 } script-eval ] with-string-writer
] unit-test
