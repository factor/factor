USING: accessors arrays assocs bit-arrays http2.hpack
io.encodings.string io.encodings.utf8 kernel literals locals
make math sequences ;

IN: http2.hpack.huffman

<<
! Table contents from RFC 7541 Appendix B
CONSTANT: huffman-table {
            {     0x1ff8  13 }
            {   0x7fffd8  23 }
            {  0xfffffe2  28 }
            {  0xfffffe3  28 }
            {  0xfffffe4  28 }
            {  0xfffffe5  28 }
            {  0xfffffe6  28 }
            {  0xfffffe7  28 }
            {  0xfffffe8  28 }
            {   0xffffea  24 }
            { 0x3ffffffc  30 }
            {  0xfffffe9  28 }
            {  0xfffffea  28 }
            { 0x3ffffffd  30 }
            {  0xfffffeb  28 }
            {  0xfffffec  28 }
            {  0xfffffed  28 }
            {  0xfffffee  28 }
            {  0xfffffef  28 }
            {  0xffffff0  28 }
            {  0xffffff1  28 }
            {  0xffffff2  28 }
            { 0x3ffffffe  30 }
            {  0xffffff3  28 }
            {  0xffffff4  28 }
            {  0xffffff5  28 }
            {  0xffffff6  28 }
            {  0xffffff7  28 }
            {  0xffffff8  28 }
            {  0xffffff9  28 }
            {  0xffffffa  28 }
            {  0xffffffb  28 }
            {       0x14   6 }
            {      0x3f8  10 }
            {      0x3f9  10 }
            {      0xffa  12 }
            {     0x1ff9  13 }
            {       0x15   6 }
            {       0xf8   8 }
            {      0x7fa  11 }
            {      0x3fa  10 }
            {      0x3fb  10 }
            {       0xf9   8 }
            {      0x7fb  11 }
            {       0xfa   8 }
            {       0x16   6 }
            {       0x17   6 }
            {       0x18   6 }
            {        0x0   5 }
            {        0x1   5 }
            {        0x2   5 }
            {       0x19   6 }
            {       0x1a   6 }
            {       0x1b   6 }
            {       0x1c   6 }
            {       0x1d   6 }
            {       0x1e   6 }
            {       0x1f   6 }
            {       0x5c   7 }
            {       0xfb   8 }
            {     0x7ffc  15 }
            {       0x20   6 }
            {      0xffb  12 }
            {      0x3fc  10 }
            {     0x1ffa  13 }
            {       0x21   6 }
            {       0x5d   7 }
            {       0x5e   7 }
            {       0x5f   7 }
            {       0x60   7 }
            {       0x61   7 }
            {       0x62   7 }
            {       0x63   7 }
            {       0x64   7 }
            {       0x65   7 }
            {       0x66   7 }
            {       0x67   7 }
            {       0x68   7 }
            {       0x69   7 }
            {       0x6a   7 }
            {       0x6b   7 }
            {       0x6c   7 }
            {       0x6d   7 }
            {       0x6e   7 }
            {       0x6f   7 }
            {       0x70   7 }
            {       0x71   7 }
            {       0x72   7 }
            {       0xfc   8 }
            {       0x73   7 }
            {       0xfd   8 }
            {     0x1ffb  13 }
            {    0x7fff0  19 }
            {     0x1ffc  13 }
            {     0x3ffc  14 }
            {       0x22   6 }
            {     0x7ffd  15 }
            {        0x3   5 }
            {       0x23   6 }
            {        0x4   5 }
            {       0x24   6 }
            {        0x5   5 }
            {       0x25   6 }
            {       0x26   6 }
            {       0x27   6 }
            {        0x6   5 }
            {       0x74   7 }
            {       0x75   7 }
            {       0x28   6 }
            {       0x29   6 }
            {       0x2a   6 }
            {        0x7   5 }
            {       0x2b   6 }
            {       0x76   7 }
            {       0x2c   6 }
            {        0x8   5 }
            {        0x9   5 }
            {       0x2d   6 }
            {       0x77   7 }
            {       0x78   7 }
            {       0x79   7 }
            {       0x7a   7 }
            {       0x7b   7 }
            {     0x7ffe  15 }
            {      0x7fc  11 }
            {     0x3ffd  14 }
            {     0x1ffd  13 }
            {  0xffffffc  28 }
            {    0xfffe6  20 }
            {   0x3fffd2  22 }
            {    0xfffe7  20 }
            {    0xfffe8  20 }
            {   0x3fffd3  22 }
            {   0x3fffd4  22 }
            {   0x3fffd5  22 }
            {   0x7fffd9  23 }
            {   0x3fffd6  22 }
            {   0x7fffda  23 }
            {   0x7fffdb  23 }
            {   0x7fffdc  23 }
            {   0x7fffdd  23 }
            {   0x7fffde  23 }
            {   0xffffeb  24 }
            {   0x7fffdf  23 }
            {   0xffffec  24 }
            {   0xffffed  24 }
            {   0x3fffd7  22 }
            {   0x7fffe0  23 }
            {   0xffffee  24 }
            {   0x7fffe1  23 }
            {   0x7fffe2  23 }
            {   0x7fffe3  23 }
            {   0x7fffe4  23 }
            {   0x1fffdc  21 }
            {   0x3fffd8  22 }
            {   0x7fffe5  23 }
            {   0x3fffd9  22 }
            {   0x7fffe6  23 }
            {   0x7fffe7  23 }
            {   0xffffef  24 }
            {   0x3fffda  22 }
            {   0x1fffdd  21 }
            {    0xfffe9  20 }
            {   0x3fffdb  22 }
            {   0x3fffdc  22 }
            {   0x7fffe8  23 }
            {   0x7fffe9  23 }
            {   0x1fffde  21 }
            {   0x7fffea  23 }
            {   0x3fffdd  22 }
            {   0x3fffde  22 }
            {   0xfffff0  24 }
            {   0x1fffdf  21 }
            {   0x3fffdf  22 }
            {   0x7fffeb  23 }
            {   0x7fffec  23 }
            {   0x1fffe0  21 }
            {   0x1fffe1  21 }
            {   0x3fffe0  22 }
            {   0x1fffe2  21 }
            {   0x7fffed  23 }
            {   0x3fffe1  22 }
            {   0x7fffee  23 }
            {   0x7fffef  23 }
            {    0xfffea  20 }
            {   0x3fffe2  22 }
            {   0x3fffe3  22 }
            {   0x3fffe4  22 }
            {   0x7ffff0  23 }
            {   0x3fffe5  22 }
            {   0x3fffe6  22 }
            {   0x7ffff1  23 }
            {  0x3ffffe0  26 }
            {  0x3ffffe1  26 }
            {    0xfffeb  20 }
            {    0x7fff1  19 }
            {   0x3fffe7  22 }
            {   0x7ffff2  23 }
            {   0x3fffe8  22 }
            {  0x1ffffec  25 }
            {  0x3ffffe2  26 }
            {  0x3ffffe3  26 }
            {  0x3ffffe4  26 }
            {  0x7ffffde  27 }
            {  0x7ffffdf  27 }
            {  0x3ffffe5  26 }
            {   0xfffff1  24 }
            {  0x1ffffed  25 }
            {    0x7fff2  19 }
            {   0x1fffe3  21 }
            {  0x3ffffe6  26 }
            {  0x7ffffe0  27 }
            {  0x7ffffe1  27 }
            {  0x3ffffe7  26 }
            {  0x7ffffe2  27 }
            {   0xfffff2  24 }
            {   0x1fffe4  21 }
            {   0x1fffe5  21 }
            {  0x3ffffe8  26 }
            {  0x3ffffe9  26 }
            {  0xffffffd  28 }
            {  0x7ffffe3  27 }
            {  0x7ffffe4  27 }
            {  0x7ffffe5  27 }
            {    0xfffec  20 }
            {   0xfffff3  24 }
            {    0xfffed  20 }
            {   0x1fffe6  21 }
            {   0x3fffe9  22 }
            {   0x1fffe7  21 }
            {   0x1fffe8  21 }
            {   0x7ffff3  23 }
            {   0x3fffea  22 }
            {   0x3fffeb  22 }
            {  0x1ffffee  25 }
            {  0x1ffffef  25 }
            {   0xfffff4  24 }
            {   0xfffff5  24 }
            {  0x3ffffea  26 }
            {   0x7ffff4  23 }
            {  0x3ffffeb  26 }
            {  0x7ffffe6  27 }
            {  0x3ffffec  26 }
            {  0x3ffffed  26 }
            {  0x7ffffe7  27 }
            {  0x7ffffe8  27 }
            {  0x7ffffe9  27 }
            {  0x7ffffea  27 }
            {  0x7ffffeb  27 }
            {  0xffffffe  28 }
            {  0x7ffffec  27 }
            {  0x7ffffed  27 }
            {  0x7ffffee  27 }
            {  0x7ffffef  27 }
            {  0x7fffff0  27 }
            {  0x3ffffee  26 }
            { 0x3fffffff  30 }
        }

:: R2, ( n -- ) n ,     n 2 64 * + ,     n 1 64 * + ,     n 3 64 * + , ;
:: R4, ( n -- ) n R2,   n 2 16 * + R2,   n 1 16 * + R2,   n 3 16 * + R2, ;
:: R6, ( n -- ) n R4,   n 2 4 * + R4,    n 1 4 * + R4,    n 3 4 * + R4, ;
>>

! The codes for each entry in the huffman table
CONSTANT: huffman-encode-table $[
    huffman-table [
        [ integer>bit-array ] dip f pad-tail reverse
    ] { } assoc>map
]

CONSTANT: EOS 256

CONSTANT: bit-reverse-table $[
    [ 0 R6, 2 R6, 1 R6, 3 R6, ] B{ } make
]

: reverse-bits ( byte-array -- byte-array' )
    [ bit-reverse-table nth ] B{ } map-as ;

: byte-array>bit-array ( byte-array -- bit-array )
    [ length 8 * ] [ bit-array boa ] bi ;

! converts a byte array/vector/sequence to a bit array, with
! each byte in descending order, such that the most significant
! bit of the first byte is the first bit in the sequence.
: bytes-to-bits ( bytes -- bits )
    reverse-bits byte-array>bit-array ;

! most significant bit first.
: bits-to-bytes ( bits -- bytes )
    underlying>> reverse-bits ;

ERROR: hpack-huffman-error message ;

! probably inefficient, but it works.
! just loops over the bits, adding each bit to the current code and searching for
! the current code, adding the corresponding symbol if the code
! is found in the table.
:: huffman-decode ( bytes -- string )
    BV{ } clone :> byte-vector
    0 0 ! current code and length
    bytes bytes-to-bits [
        [ 2 * ] 2dip 1 0 ? swap 1 [ + ] 2bi@ 
        2dup 2array huffman-table index
        [
            dup EOS = [ "End of Stream in huffman encoded string" hpack-huffman-error ] when
            byte-vector push 2drop 0 0
        ] when*
    ] each

    7 > [ "Padding is too long in huffman encoded string" hpack-huffman-error ] when

    EOS huffman-table nth first integer>bit-array
    swap integer>bit-array tail?
    [ "Padding is not the most significant bits of the End of Stream code in huffman encoded string" hpack-huffman-error ] unless

    byte-vector utf8 decode ;

: huffman-encode ( string -- bytes )
    [ huffman-encode-table nth ] { } map-as concat
    EOS huffman-encode-table nth over length neg 8 rem head
    append bits-to-bytes ;

