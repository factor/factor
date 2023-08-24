USING: base64 byte-arrays io.encodings.ascii io.encodings.string
kernel sequences splitting strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base64 base64> = ] unit-test

{ "abcdefghijklmnopqrstuvwxyz" } [ "abcdefghijklmnopqrstuvwxyz" ascii encode >base64 base64> ascii decode
] unit-test
{ "" } [ "" ascii encode >base64 base64> ascii decode ] unit-test
{ "a" } [ "a" ascii encode >base64 base64> ascii decode ] unit-test
{ "ab" } [ "ab" ascii encode >base64 base64> ascii decode ] unit-test
{ "abc" } [ "abc" ascii encode >base64 base64> ascii decode ] unit-test
{ "abcde" } [ "abcde" ascii encode >base64 3 cut "\r\n" swap 3append base64> ascii decode ] unit-test

! From http://en.wikipedia.org/wiki/Base64
{ "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=" }
[
    "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    ascii encode >base64 >string
] unit-test

{ "TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz\r\nIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg\r\ndGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu\r\ndWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo\r\nZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=" }
[
    "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."
    ascii encode >base64-lines >string
] unit-test

[ { 33 52 17 40 12 51 33 43 18 33 23 } base64> ]
[ malformed-base64? ] must-fail-with

{
    {
        B{ 123 34 97 108 103 34 58 34 72 83 50 53 54 34 125 }
        B{ 123 34 115 117 98 34 58 34 74 111 101 34 125 }
        B{
            138 151 175 68 219 145 63 161 223 148 111 28 20 169 230
            80 251 114 166 187 145 11 135 219 212 53 173 160 178 250
            217 38
        }
    }
} [
    "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJKb2UifQ.ipevRNuRP6HflG8cFKnmUPtypruRC4fb1DWtoLL62SY"
    "." split [ base64> ] map
] unit-test

{ "01a+b/cd" } [ "\xd3V\xbeo\xf7\x1d" >base64 "" like ] unit-test
{ "\xd3V\xbeo\xf7\x1d" } [ "01a+b/cd" base64> "" like ] unit-test

{ "01a-b_cd" } [ "\xd3V\xbeo\xf7\x1d" >urlsafe-base64 "" like ] unit-test
{ "\xd3V\xbeo\xf7\x1d" } [ "01a-b_cd" urlsafe-base64> "" like ] unit-test

{ "eyJhIjoiYmNkIn0" }
[ "{\"a\":\"bcd\"}" >urlsafe-base64-jwt >string ] unit-test

{ "{\"a\":\"bcd\"}" }
[ "{\"a\":\"bcd\"}" >urlsafe-base64-jwt urlsafe-base64> >string ] unit-test

{ "" } [ "" >base64 >string ] unit-test
{ "Zg==" } [ "f" >base64 >string ] unit-test
{ "Zm8=" } [ "fo" >base64 >string ] unit-test
{ "Zm9v" } [ "foo" >base64 >string ] unit-test
{ "Zm9vYg==" } [ "foob" >base64 >string ] unit-test
{ "Zm9vYmE=" } [ "fooba" >base64 >string ] unit-test
{ "Zm9vYmFy" } [ "foobar" >base64 >string ] unit-test

{ "" } [ "" base64> >string ] unit-test
{ "f" } [ "Zg==" base64> >string ] unit-test
{ "fo" } [ "Zm8=" base64> >string ] unit-test
{ "foo" } [ "Zm9v" base64> >string ] unit-test
{ "foob" } [ "Zm9vYg==" base64> >string ] unit-test
{ "fooba" } [ "Zm9vYmE=" base64> >string ] unit-test
{ "foobar" } [ "Zm9vYmFy" base64> >string ] unit-test
