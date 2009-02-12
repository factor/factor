! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays destructors fry io kernel locals
math sequences ;
IN: bitstreams

TUPLE: bitstream stream current-bits #bits disposed ;
TUPLE: bitstream-reader < bitstream ;

: reset-bitstream ( stream -- stream )
    0 >>#bits 0 >>current-bits ; inline

: new-bitstream ( stream class -- bitstream )
    new
        swap >>stream
        reset-bitstream ; inline

M: bitstream-reader dispose ( stream -- )
    stream>> dispose ;

: <bitstream-reader> ( stream -- bitstream )
    bitstream-reader new-bitstream ; inline

: read-next-byte ( bitstream -- bitstream )
    dup stream>> stream-read1
    [ >>current-bits ] [ 8 0 ? >>#bits ] bi ; inline

: maybe-read-next-byte ( bitstream -- bitstream )
    dup #bits>> 0 = [ read-next-byte ] when ; inline

: shift-one-bit ( bitstream -- n )
    [ current-bits>> ] [ #bits>> ] bi 1- neg shift 1 bitand ; inline

: next-bit ( bitstream -- n )
    maybe-read-next-byte [
        shift-one-bit
    ] [
        [ 1- ] change-#bits maybe-read-next-byte drop
    ] bi ; inline

: read-bit ( bitstream -- n )
    dup #bits>> 1 = [
        [ current-bits>> 1 bitand ]
        [ read-next-byte drop ] bi
    ] [
        next-bit
    ] if ; inline

: bits>integer ( seq -- n )
    0 [ [ 1 shift ] dip bitor ] reduce ; inline

: read-bits ( width bitstream -- n )
    '[ _ read-bit ] replicate bits>integer ; inline


TUPLE: bitstream-writer < bitstream ;

: <bitstream-writer> ( stream -- bitstream )
    bitstream-writer new-bitstream ; inline

: write-bit ( n bitstream -- )
    [ 1 shift bitor ] change-current-bits
    [ 1+ ] change-#bits
    dup #bits>> 8 = [
        [ [ current-bits>> ] [ stream>> stream-write1 ] bi ]
        [ reset-bitstream drop ] bi
    ] [
        drop
    ] if ; inline

ERROR: invalid-bit-width n ;

:: write-bits ( n width bitstream -- )
    n 0 < [ n invalid-bit-width ] when
    n 0 = [
        width [ 0 bitstream write-bit ] times
    ] [
        width n log2 1+ dup :> n-length - [ 0 bitstream write-bit ] times
        n-length [
            n-length swap - 1- neg n swap shift 1 bitand
            bitstream write-bit
        ] each
    ] if ;

: flush-bits ( bitstream -- ) stream>> stream-flush ;

: bitstream-output ( bitstream -- bytes ) stream>> >byte-array ;
