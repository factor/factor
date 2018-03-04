! Copyright (C) 2018 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays checksums checksums.md5 checksums.multi
checksums.sha io io.encodings.binary io.files namespaces tools.test ;
IN: checksums.multi.tests

{
    {
        B{ 9 143 107 205 70 33 211 115 202 222 78 131 38 39 180 246 }
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
