! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays checksums checksums.md5 checksums.multi
checksums.sha io io.encodings.binary io.files namespaces tools.test ;
IN: checksums.multi.tests

{
    {
        B{ 155 181 180 45 142 211 121 3 86 11 19 254 46 110 208 53 }
        B{
            185 16 47 6 163 92 254 132 223 97 1 55 165 73 57 87 243
            209 7 104
        }
    }
} [
    "test" >byte-array { md5 sha1 } <multi-checksum> checksum-bytes
] unit-test

{
    {
        B{ 220 158 207 218 50 163 198 36 234 90 122 65 197 14 224 16 }
        B{
            132 132 148 224 101 202 198 114 38 53 127 18 70 170 108
            53 25 255 174 207
        }
    }
} [
    "resource:LICENSE.txt" binary [
        input-stream get { md5 sha1 } <multi-checksum> checksum-stream
    ] with-file-reader
] unit-test
