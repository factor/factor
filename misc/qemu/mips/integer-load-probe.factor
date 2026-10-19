! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays alien.c-types alien.data compiler.units endian io io.encodings
io.encodings.string io.encodings.utf32 kernel locals math prettyprint sequences ;
IN: mips.integer-load-validation

:: signed-roundtrip ( n -- ? ) n int <ref> int deref n = ;
:: unsigned-roundtrip ( n -- ? ) n uint <ref> uint deref n = ;
: decode-be ( -- chars ) B{ 0 0 0 120 0 1 209 30 } utf32be decode >array ;
: read-be ( -- n ) B{ 0 0 0 120 } be> ;
{ signed-roundtrip unsigned-roundtrip decode-be read-be } compile

{ -2147483648 -1791000000 -134217729 134217728 1791000000 2147483647 }
[ signed-roundtrip [ ] [ "signed 32-bit load lost integer bits" throw ] if ] each
{ 134217728 2013265920 2147483648 4294967295 }
[ unsigned-roundtrip [ ] [ "unsigned 32-bit load lost integer bits" throw ] if ] each
read-be 120 = [ ] [ "big-endian word decoding failed" throw ] if
decode-be { 120 119070 } = [ ] [ "UTF32BE decoding failed" throw ] if
"MIPS full-width signed/unsigned loads and UTF32BE PASS" print flush
