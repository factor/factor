USING: checksums.hmac checksums.md5 checksums.sha hex-strings
sequences strings tools.test ;

{
    "\u000092\u000094rz68\u0000bb\u00001c\u000013\u0000f4\u00008e\u0000f8\u000015\u00008b\u0000fc\u00009d"
} [
    "Hi There" 16 11 <string> md5 hmac-bytes >string ] unit-test

{ "u\u00000cx>j\u0000b0\u0000b5\u000003\u0000ea\u0000a8n1\n]\u0000b78" }
[ "what do ya want for nothing?" "Jefe" md5 hmac-bytes >string ] unit-test

{
    "V\u0000be4R\u00001d\u000014L\u000088\u0000db\u0000b8\u0000c73\u0000f0\u0000e8\u0000b3\u0000f6"
}
[
    50 0xdd <repetition>
    16 0xaa <string> md5 hmac-bytes >string
] unit-test

{
    "g[\u00000b:\eM\u0000dfN\u000012Hr\u0000dal/c+\u0000fe\u0000d9W\u0000e9"
} [
    "Hi There" 16 11 <string> sha1 hmac-bytes >string
] unit-test

{
    "\u0000ef\u0000fc\u0000dfj\u0000e5\u0000eb/\u0000a2\u0000d2t\u000016\u0000d5\u0000f1\u000084\u0000df\u00009c%\u00009a|y"
} [
    "what do ya want for nothing?" "Jefe" sha1 hmac-bytes >string
] unit-test

{
    "\u0000d70YM\u000016~5\u0000d5\u000095o\u0000d8\0=\r\u0000b3\u0000d3\u0000f4m\u0000c7\u0000bb"
} [
    50 0xdd <repetition>
    16 0xaa <string> sha1 hmac-bytes >string
] unit-test

{ "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7" }
[ "Hi There" 20 0xb <string> sha-256 hmac-bytes bytes>hex-string ] unit-test

{ "167f928588c5cc2eef8e3093caa0e87c9ff566a14794aa61648d81621a2a40c6" }
[
    "what do ya want for nothing?"
    "JefeJefeJefeJefeJefeJefeJefeJefe" sha-256 hmac-bytes bytes>hex-string
] unit-test
