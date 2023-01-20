! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: checksums.interleave checksums.sha tools.test ;

{
    B{
        59 155 253 205 75 163 94 115 208 42 227 92 181 19 60 232
        119 65 178 131 210 48 241 230 204 216 30 156 4 215 80 84 93
        206 44 1 18 128 150 153
    }
} [
    B{
        102 83 241 12 26 250 181 76 97 200 37 117 168 74 254 48 216
        170 26 58 150 150 179 24 153 146 191 225 203 127 166 167
    }
    sha1 interleaved-checksum
] unit-test
