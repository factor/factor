! Copyright (C) Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data
byte-arrays classes.struct destructors generalizations kernel
libc math math.order sequences sequences.private typed ;
IN: benchmark.yuv-to-rgb

STRUCT: yuv-buffer
    { y_width int }
    { y_height int }
    { y_stride int }
    { uv_width int }
    { uv_height int }
    { uv_stride int }
    { y void* }
    { u void* }
    { v void* } ;

:: fake-data ( -- rgb yuv )
    1600 :> w
    1200 :> h
    yuv-buffer <struct> :> buffer
    w h * 3 * <byte-array> :> rgb
    rgb buffer
        w >>y_width
        h >>y_height
        h >>uv_height
        w >>y_stride
        w >>uv_stride
        w h * <iota> [ dup * ] B{ } map-as malloc-byte-array &free >>y
        w h * 2/ <iota> [ dup dup * * ] B{ } map-as malloc-byte-array &free >>u
        w h * 2/ <iota> [ dup * dup * ] B{ } map-as malloc-byte-array &free >>v ;

: clamp ( n -- n )
    255 min 0 max ; inline

: stride ( line yuv  -- uvy yy )
    [ uv_stride>> swap 2/ * ] [ y_stride>> * ] 2bi ; inline

: compute-y ( yuv uvy yy x -- y )
    + >fixnum nip swap y>> swap alien-unsigned-1 16 - ; inline

: compute-v ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap u>> swap alien-unsigned-1 128 - ; inline

: compute-u ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap v>> swap alien-unsigned-1 128 - ; inline

:: compute-yuv ( yuv uvy yy x -- y u v )
    yuv uvy yy x compute-y
    yuv uvy yy x compute-u
    yuv uvy yy x compute-v ; inline

: compute-blue ( y u v -- b )
    drop 516 * 128 + swap 298 * + -8 shift clamp ; inline

: compute-green ( y u v -- g )
    [ [ 298 * ] dip 100 * - ] dip 208 * - 128 + -8 shift clamp ; inline

: compute-red ( y u v -- g )
    nip 409 * swap 298 * + 128 + -8 shift clamp ; inline

: compute-rgb ( y u v -- b g r )
    [ compute-blue ] [ compute-green ] [ compute-red ] 3tri ; inline

: store-rgb ( index rgb b g r -- index )
    [ pick 0 + pick set-nth-unsafe ]
    [ pick 1 + pick set-nth-unsafe ]
    [ pick 2 + pick set-nth-unsafe ] tri*
    drop ; inline

: yuv>rgb-pixel ( index rgb yuv uvy yy x -- index )
    compute-yuv compute-rgb store-rgb 3 + ; inline

: yuv>rgb-row ( index rgb yuv y -- index )
    over stride
    pick y_width>> <iota>
    [ yuv>rgb-pixel ] 4 nwith each ; inline

TYPED: yuv>rgb ( rgb: byte-array yuv: yuv-buffer -- )
    [ 0 ] 2dip
    dup y_height>> <iota>
    [ yuv>rgb-row ] 2with each
    drop ;

: yuv-to-rgb-benchmark ( -- )
    [ fake-data yuv>rgb ] with-destructors ;

MAIN: yuv-to-rgb-benchmark
