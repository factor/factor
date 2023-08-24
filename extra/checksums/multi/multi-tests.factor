! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays checksums checksums.md5 checksums.multi
checksums.sha tools.test ;
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
