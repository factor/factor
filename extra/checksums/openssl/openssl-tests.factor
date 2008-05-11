IN: checksums.openssl.tests
USING: byte-arrays checksums.openssl checksums tools.test
accessors kernel system ;

[
    B{ 201 238 222 100 92 200 182 188 138 255 129 163 115 88 240 136 }
]
[
    "Hello world from the openssl binding" >byte-array
    "md5" <openssl-checksum> checksum-bytes
] unit-test

[
  B{ 63 113 237 255 181 5 152 241 136 181 43 95 160 105 44 87 49 82 115 0 }
]
[
    "Hello world from the openssl binding" >byte-array
    "sha1" <openssl-checksum> checksum-bytes
] unit-test

[
    "Bad checksum test" >byte-array
    "no such checksum" <openssl-checksum>
    checksum-bytes
] [ [ unknown-digest? ] [ name>> "no such checksum" = ] bi and ]
must-fail-with

[ ] [ image openssl-sha1 checksum-file drop ] unit-test
