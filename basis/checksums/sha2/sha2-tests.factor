USING: arrays kernel math namespaces sequences tools.test
checksums.sha2 checksums ;
IN: checksums.sha2.tests

: test-checksum ( text identifier -- checksum )
    checksum-bytes hex-string ;

[ "75388b16512776cc5dba5da1fd890150b0c6455cb4f58b1952522525" ]
[
    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
    sha-224 test-checksum
] unit-test

[ "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]
[ "" sha-256 test-checksum ] unit-test

[ "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad" ]
[ "abc" sha-256 test-checksum ] unit-test

[ "f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650" ]
[ "message digest" sha-256 test-checksum ] unit-test

[ "71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73" ]
[ "abcdefghijklmnopqrstuvwxyz" sha-256 test-checksum ] unit-test

[ "db4bfcbd4da0cd85a60c3c37d3fbd8805c77f15fc6b1fdfe614ee0a7c8fdb4c0" ]
[
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    sha-256 test-checksum
] unit-test

[ "f371bc4a311f2b009eef952dd83ca80e2b60026c8e935592d0f9c308453c813e" ]
[
    "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
    sha-256 test-checksum
] unit-test




! [ "8e959b75dae313da8cf4f72814fc143f8f7779c6eb9f7fa17299aeadb6889018501d289e4900f7e4331b99dec4b5433ac7d329eeb6dd26545e96e55b874be909" ]
! [ "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" sha-512 test-checksum ] unit-test
