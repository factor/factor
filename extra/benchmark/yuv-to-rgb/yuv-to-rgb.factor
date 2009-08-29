! Copyright (C) Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.c-types alien.syntax byte-arrays
destructors generalizations hints kernel libc locals math math.order
sequences sequences.private ;
IN: benchmark.yuv-to-rgb

C-STRUCT: yuv_buffer
    { "int" "y_width" }
    { "int" "y_height" }
    { "int" "y_stride" }
    { "int" "uv_width" }
    { "int" "uv_height" }
    { "int" "uv_stride" }
    { "void*" "y" }
    { "void*" "u" }
    { "void*" "v" } ;

:: fake-data ( -- rgb yuv )
    [let* | w [ 1600 ]
            h [ 1200 ]
            buffer [ "yuv_buffer" <c-object> ]
            rgb [ w h * 3 * <byte-array> ] |
        w buffer set-yuv_buffer-y_width
        h buffer set-yuv_buffer-y_height
        h buffer set-yuv_buffer-uv_height
        w buffer set-yuv_buffer-y_stride
        w buffer set-yuv_buffer-uv_stride
        w h * [ dup * ] B{ } map-as malloc-byte-array &free buffer set-yuv_buffer-y
        w h * 2/ [ dup dup * * ] B{ } map-as malloc-byte-array &free buffer set-yuv_buffer-u
        w h * 2/ [ dup * dup * ] B{ } map-as malloc-byte-array &free buffer set-yuv_buffer-v
        rgb buffer
    ] ;

: clamp ( n -- n )
    255 min 0 max ; inline

: stride ( line yuv  -- uvy yy )
    [ yuv_buffer-uv_stride swap 2/ * ] [ yuv_buffer-y_stride * ] 2bi ; inline

: compute-y ( yuv uvy yy x -- y )
    + >fixnum nip swap yuv_buffer-y swap alien-unsigned-1 16 - ; inline

: compute-v ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap yuv_buffer-u swap alien-unsigned-1 128 - ; inline

: compute-u ( yuv uvy yy x -- v )
    nip 2/ + >fixnum swap yuv_buffer-v swap alien-unsigned-1 128 - ; inline

:: compute-yuv ( yuv uvy yy x -- y u v )
    yuv uvy yy x compute-y
    yuv uvy yy x compute-u
    yuv uvy yy x compute-v ; inline

: compute-blue ( y u v -- b )
    drop 516 * 128 + swap 298 * + -8 shift clamp ; inline

: compute-green ( y u v -- g )
    [ [ 298 * ] dip 100 * - ] dip 208 * - 128 + -8 shift clamp ;
    inline

: compute-red ( y u v -- g )
    nip 409 * swap 298 * + 128 + -8 shift clamp ; inline

: compute-rgb ( y u v -- b g r )
    [ compute-blue ] [ compute-green ] [ compute-red ] 3tri ;
    inline

: store-rgb ( index rgb b g r -- index )
    [ pick 0 + pick set-nth-unsafe ]
    [ pick 1 + pick set-nth-unsafe ]
    [ pick 2 + pick set-nth-unsafe ] tri*
    drop ; inline

: yuv>rgb-pixel ( index rgb yuv uvy yy x -- index )
    compute-yuv compute-rgb store-rgb 3 + ; inline

: yuv>rgb-row ( index rgb yuv y -- index )
    over stride
    pick yuv_buffer-y_width
    [ yuv>rgb-pixel ] with with with with each ; inline

: yuv>rgb ( rgb yuv -- )
    [ 0 ] 2dip
    dup yuv_buffer-y_height
    [ yuv>rgb-row ] with with each
    drop ;

HINTS: yuv>rgb byte-array byte-array ;

: yuv>rgb-benchmark ( -- )
    [ fake-data yuv>rgb ] with-destructors ;

MAIN: yuv>rgb-benchmark
