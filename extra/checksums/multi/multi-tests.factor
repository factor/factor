! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays checksums checksums.md5 checksums.multi
checksums.sha io io.encodings.binary io.files namespaces tools.test ;
IN: checksums.multi.tests

{
    {
        B{
            9 143 107 205 70 33 211 115 202 222 78 131 38 39 180 246
        }
        B{
            169 74 143 229 204 177 155 166 28 76 8 115 211 145 233
            135 152 47 187 211
        }
    }
} [
    "test" >byte-array { md5 sha1 } <multi-checksum> checksum-bytes
] unit-test

{
    {
        B{ 155 181 180 45 142 211 121 3 86 11 19 254 46 110 208 53 }
        B{
            185 16 47 6 163 92 254 132 223 97 1 55 165 73 57 87 243
            209 7 104
        }
    }
} [
    "resource:LICENSE.txt" binary [
        input-stream get { md5 sha1 } <multi-checksum> checksum-stream
    ] with-file-reader
] unit-test
