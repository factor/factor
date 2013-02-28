! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data ascii byte-arrays byte-vectors grouping io
io.encodings.binary io.files io.streams.string kernel math math.parser
sequences variables prettyprint ;

IN: tools.hexdump

<PRIVATE

VAR: hexdump-group 1 set: hexdump-group
VAR: hexdump-address f set: hexdump-address
: write-header ( len -- )
    hexdump-address
    [ "Address: 0x" write
      hexdump-address alien-address >hex
      " " append write 
    ] when
    "Length: " write
    [ number>string write "d, " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    hexdump-address
    [ "0x" write
      16 * hexdump-address alien-address +
      >hex  16 CHAR: 0 pad-head
      " " append  write ] 
    [ 16 * >hex 8 CHAR: 0 pad-head  " " append write ]
    if ;

: group-digits ( seq -- seq )
    hexdump-group dup [ ] [ drop 1 ] if
    group
    [ concat " " append ] { } map-as ;

: >hex-digit ( digit -- str )
    >hex 2 CHAR: 0 pad-head ;

: >hex-digits ( bytes -- str )
    [ >hex-digit ] { } map-as 
    group-digits concat
    32 CHAR: \s pad-tail ;

: >ascii ( bytes -- str )
    [ [ printable? ] keep CHAR: . ? ] "" map-as ;

: write-hex-line ( bytes lineno -- )
    write-offset [ >hex-digits write ] [ >ascii write ] bi nl ;

: hexdump-bytes ( bytes -- )
    [ length write-header ]
    [ 16 <sliced-groups> [ write-hex-line ] each-index ] bi ;

: hexdump-set-address ( n -- )  set: hexdump-address ;
PRIVATE>

GENERIC: hexdump. ( byte-array -- )

M: byte-array hexdump. f hexdump-set-address hexdump-bytes ;

M: byte-vector hexdump. f hexdump-set-address hexdump-bytes ;

GENERIC: .nhexdump ( n obj -- )
M: alien .nhexdump  dup hexdump-set-address  swap memory>byte-array hexdump-bytes ;

: hexdump ( byte-array -- str )
    [ hexdump. ] with-string-writer ;

: hexdump-file ( path -- )
    binary file-contents hexdump. ;

: hexdump1 ( -- )  1 set: hexdump-group ;
: hexdump2 ( -- )  2 set: hexdump-group ;
: hexdump4 ( -- )  4 set: hexdump-group ;
: hexdump8 ( -- )  8 set: hexdump-group ;
