USING: arrays kernel math namespaces sequences tools.test crypto.sha1 ;

[ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" string>sha1str ] unit-test
[ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" string>sha1str ] unit-test
! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1str ] unit-test ! takes a long time...
[ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567"
10 swap <array> concat string>sha1str ] unit-test

[
    ";\u009b\u00fd\u00cdK\u00a3^s\u00d0*\u00e3\\\u00b5\u0013<\u00e8wA\u00b2\u0083\u00d20\u00f1\u00e6\u00cc\u00d8\u001e\u009c\u0004\u00d7PT]\u00ce,\u0001\u0012\u0080\u0096\u0099"
] [
    "\u0066\u0053\u00f1\u000c\u001a\u00fa\u00b5\u004c\u0061\u00c8\u0025\u0075\u00a8\u004a\u00fe\u0030\u00d8\u00aa\u001a\u003a\u0096\u0096\u00b3\u0018\u0099\u0092\u00bf\u00e1\u00cb\u007f\u00a6\u00a7"
    string>sha1-interleave
] unit-test
