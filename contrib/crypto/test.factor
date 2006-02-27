USING: kernel math test namespaces crypto ;

[ HEX: 1f63edfb7e838622c7412eafaf0439cf0cdf3aae8bdd09e2de69b509a53883a83560d5ce50ea039e4 ] [  HEX: 827c67f31b2b46afa49ed95d7f7a3011e5875f7052d4c55437ce726d3c6ce0dc9c445fda63b6dc4e 16 barrett-mu ] unit-test

[ "abcdefghijklmnopqrstuvwxyz" ] [ "abcdefghijklmnopqrstuvwxyz" >base64 base64> ] unit-test
[ "" ] [ "" >base64 base64> ] unit-test
[ "a" ] [ "a" >base64 base64> ] unit-test
[ "ab" ] [ "ab" >base64 base64> ] unit-test
[ "abc" ] [ "abc" >base64 base64> ] unit-test

[ HEX: 7155b978fed765e2ec80b472b4eae1154d2f75dd753e7efaca0449b8eaf7c047f94564302c80c717 ] [ HEX: c8d30cdd849cc1cbccf75340f903cde3acc0e7b5e0326aa91f82f442cc1ab23f66cf042c2af22a0b montgomery-r^2 ] unit-test

[ HEX: 5aee1477 ] [ HEX: d681fab9 32 montgomery-n0' ] unit-test

[ "d41d8cd98f00b204e9800998ecf8427e" ] [ "" string>md5str ] unit-test
[ "0cc175b9c0f1b6a831c399e269772661" ] [ "a" string>md5str ] unit-test
[ "900150983cd24fb0d6963f7d28e17f72" ] [ "abc" string>md5str ] unit-test
[ "f96b697d7cb7938d525a2f31aaf161d0" ] [ "message digest" string>md5str ] unit-test
[ "c3fcd3d76192e4007dfb496cca67e13b" ] [ "abcdefghijklmnopqrstuvwxyz" string>md5str ] unit-test
[ "d174ab98d277d9f5a5611c2c9f419d9f" ] [ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" string>md5str ] unit-test
[ "57edf4a22be3c955ac49da2e2107b67a" ] [ "12345678901234567890123456789012345678901234567890123456789012345678901234567890" string>md5str ] unit-test

[ "a9993e364706816aba3e25717850c26c9cd0d89d" ] [ "abc" string>sha1str ] unit-test
[ "84983e441c3bd26ebaae4aa1f95129e5e54670f1" ] [ "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" string>sha1str ] unit-test
! [ "34aa973cd4c4daa4f61eeb2bdbad27316534016f" ] [ 1000000 CHAR: a fill string>sha1str ] unit-test ! takes a long time...
[ "dea356a2cddd90c7a7ecedc5ebb563934f460452" ] [ "0123456701234567012345670123456701234567012345670123456701234567" [ 10 [ dup % ] times ] "" make nip string>sha1str ] unit-test

[ f ] [ 473155932665450549999756893736999469773678960651272093993257221235459777950185377130233556540099119926369437865330559863 miller-rabin ] unit-test
[ t ] [ 37 miller-rabin ] unit-test
[ 101 ] [ 100 next-miller-rabin-prime ] unit-test
[ 100000000000031 ] [ 100000000000000 next-miller-rabin-prime ] unit-test


[ 123456789 ] [ 512 generate-key-pair 123456789 over rsa-encrypt swap rsa-decrypt ] unit-test


