! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test checksums checksums.sodium ;
IN: checksums.sodium.tests

CONSTANT: test-lines { "Hello," "world!" }
CONSTANT: key B{ 1 2 3 4 5 }

{ B{
    139 36 186 84 68 114 23 158 49 88 99 135 7 27 173 126 1 166
    211 245 212 87 23 116 86 191 32 15 106 139 134 168 184 156
    246 65 84 90 77 78 127 26 18 229 103 211 131 111 224 131 48
    77 157 208 10 231 152 223 132 200 228 141 25 64
} } [ test-lines 64 f <sodium-checksum> checksum-lines ] unit-test

{ B{
    51 107 65 253 93 78 146 11 36 184 39 107 133 237 22 60 249
    171 78 26 189 168 126 117 78 134 62 73 166 1 208 132 76 197
    54 33 174 82 148 192 158 211 190 77 104 154 39 187 128 118
    216 161 100 21 241 244 199 135 79 62 233 12 137 185
} } [ test-lines 64 key <sodium-checksum> checksum-lines ] unit-test
