USING: kernel math test namespaces crypto ;

[ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" string>sha1str ] unit-test
[ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" string>sha1str ] unit-test
! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1str ] unit-test ! takes a long time...
[ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567" [ 10 [ dup % ] times ] "" make nip string>sha1str ] unit-test

