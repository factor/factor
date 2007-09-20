USING: kernel math namespaces crypto.md5 tools.test ;

[ "d41d8cd98f00b204e9800998ecf8427e" ] [ "" string>md5str ] unit-test
[ "0cc175b9c0f1b6a831c399e269772661" ] [ "a" string>md5str ] unit-test
[ "900150983cd24fb0d6963f7d28e17f72" ] [ "abc" string>md5str ] unit-test
[ "f96b697d7cb7938d525a2f31aaf161d0" ] [ "message digest" string>md5str ] unit-test
[ "c3fcd3d76192e4007dfb496cca67e13b" ] [ "abcdefghijklmnopqrstuvwxyz" string>md5str ] unit-test
[ "d174ab98d277d9f5a5611c2c9f419d9f" ] [ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" string>md5str ] unit-test
[ "57edf4a22be3c955ac49da2e2107b67a" ] [ "12345678901234567890123456789012345678901234567890123456789012345678901234567890" string>md5str ] unit-test

