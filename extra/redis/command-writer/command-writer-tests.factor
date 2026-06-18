! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel redis.command-writer tools.test ;
IN: redis.command-writer.tests

! Each command word takes a sequence of arguments and writes a RESP
! array of bulk strings (UTF-8, byte-length prefixed) to the current
! binary output stream, in Redis' natural argument order.

: written ( quot -- string )
    [ binary ] dip with-byte-writer utf8 decode ; inline

! Connection
{ "*1\r\n$4\r\nPING\r\n" }
[ [ { } ping ] written ] unit-test

{ "*2\r\n$4\r\nAUTH\r\n$8\r\npassword\r\n" }
[ [ { "password" } auth ] written ] unit-test

! String values
{ "*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$3\r\nfoo\r\n" }
[ [ { "key" "foo" } set ] written ] unit-test

{ "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n" }
[ [ { "key" } get ] written ] unit-test

! Numbers are stringified
{ "*3\r\n$6\r\nEXPIRE\r\n$3\r\nkey\r\n$2\r\n60\r\n" }
[ [ { "key" 60 } expire ] written ] unit-test

! Multibyte values use the UTF-8 byte count, not the character count
{ "*3\r\n$3\r\nSET\r\n$1\r\nk\r\n$6\r\nhéllo\r\n" }
[ [ { "k" "héllo" } set ] written ] unit-test

! Variadic
{ "*4\r\n$4\r\nMGET\r\n$4\r\nkey1\r\n$4\r\nkey2\r\n$4\r\nkey3\r\n" }
[ [ { "key1" "key2" "key3" } mget ] written ] unit-test

! Natural argument order (LRANGE key start stop)
{ "*4\r\n$6\r\nLRANGE\r\n$3\r\nkey\r\n$1\r\n0\r\n$2\r\n-1\r\n" }
[ [ { "key" 0 -1 } lrange ] written ] unit-test

! Hashes
{ "*4\r\n$4\r\nHSET\r\n$3\r\nkey\r\n$5\r\nfield\r\n$5\r\nvalue\r\n" }
[ [ { "key" "field" "value" } hset ] written ] unit-test

! Container subcommands write both tokens
{ "*2\r\n$3\r\nACL\r\n$6\r\nWHOAMI\r\n" }
[ [ { } acl-whoami ] written ] unit-test

{ "*3\r\n$6\r\nCONFIG\r\n$3\r\nGET\r\n$9\r\nmaxmemory\r\n" }
[ [ { "maxmemory" } config-get ] written ] unit-test

{ "*3\r\n$6\r\nSCRIPT\r\n$4\r\nLOAD\r\n$8\r\nreturn 1\r\n" }
[ [ { "return 1" } script-load ] written ] unit-test

! write-command directly: ( args command -- )
{ "*3\r\n$4\r\nHGET\r\n$3\r\nkey\r\n$5\r\nfield\r\n" }
[ [ { "key" "field" } { "HGET" } write-command ] written ] unit-test
