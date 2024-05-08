! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays checksums checksums.md5 hex-strings
io.encodings.binary io.streams.byte-array kernel sequences
tools.test ;

{ "d41d8cd98f00b204e9800998ecf8427e" } [ "" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "0cc175b9c0f1b6a831c399e269772661" } [ "a" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "900150983cd24fb0d6963f7d28e17f72" } [ "abc" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "f96b697d7cb7938d525a2f31aaf161d0" } [ "message digest" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "c3fcd3d76192e4007dfb496cca67e13b" } [ "abcdefghijklmnopqrstuvwxyz" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "d174ab98d277d9f5a5611c2c9f419d9f" } [ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test
{ "57edf4a22be3c955ac49da2e2107b67a" } [ "12345678901234567890123456789012345678901234567890123456789012345678901234567890" >byte-array md5 checksum-bytes bytes>hex-string ] unit-test


{
    t
} [
    <md5-state> "asdf" add-checksum-bytes
    [ get-checksum ] [ get-checksum ] bi =
] unit-test

{
    t
} [
    <md5-state> "" add-checksum-bytes
    [ get-checksum ] [ get-checksum ] bi =
] unit-test

{
    t
} [
    <md5-state> "asdf" binary <byte-reader> add-checksum-stream
    [ get-checksum ] [ get-checksum ] bi =
] unit-test

{
    t
} [
    { "abcd" "efg" } md5 checksum-lines length 16 =
] unit-test
