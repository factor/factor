! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators cpu.architecture kernel locals
math math.bitwise math.floats.small math.floats.small.bfloat math.functions math.libm math.order
math.vectors math.vectors.simd math.vectors.simd.intrinsics.private
sequences system vocabs vocabs.loader ;
IN: math.vectors.simd.extensions

! Stable public contracts are shared by the scalar and optional ARM kernels.
! A is row-major, B is column-major, and accumulators/results are row-major.
HOOK: (vdot4+) cpu ( a b accumulator -- result )
HOOK: (vmatmul2x8+) cpu ( a b accumulator -- result )
HOOK: (vbdot2+) cpu ( a b accumulator -- result )
HOOK: (vbmatmul2x4+) cpu ( a b accumulator -- result )
HOOK: half-binary cpu ( a b op -- result )
HOOK: half-fma cpu ( a b accumulator -- result )
HOOK: half-sqrt cpu ( a -- result )
HOOK: pack-half cpu ( lo hi -- result )
HOOK: pack-bfloat cpu ( lo hi -- result )

M:: object (vdot4+) ( a b accumulator -- result )
    4 <iota> [| lane |
        lane accumulator nth
        4 <iota> swap [| value j |
            lane 4 * j + :> index
            index a nth index b nth * value +
        ] reduce
    ] accumulator map-as ;

M:: object (vmatmul2x8+) ( a b accumulator -- result )
    4 <iota> [| lane |
        lane accumulator nth
        8 <iota> swap [| value j |
            lane 2 /i 8 * j + a nth
            lane 2 mod 8 * j + b nth * value +
        ] reduce
    ] accumulator map-as ;

M:: object (vbdot2+) ( a b accumulator -- result )
    4 <iota> [| lane |
        lane accumulator nth
        lane 2 * a nth lane 2 * 1 + a nth
        lane 2 * b nth lane 2 * 1 + b nth bfloat-dot-add
    ] float-4 new map-as ;

M:: object (vbmatmul2x4+) ( a b accumulator -- result )
    4 <iota> [| lane |
        lane 2 /i 4 * :> row
        lane 2 mod 4 * :> column
        lane accumulator nth
        row a nth row 1 + a nth column b nth column 1 + b nth bfloat-dot-add
        row 2 + a nth row 3 + a nth column 2 + b nth column 3 + b nth bfloat-dot-add
    ] float-4 new map-as ;

<PRIVATE
: byte-vector? ( v -- ? ) [ char-16? ] [ uchar-16? ] bi or ;
:: check-integer-accumulate ( a b accumulator -- )
    a byte-vector? b byte-vector? and
    a uchar-16? b uchar-16? and
    [ accumulator uint-4? ] [ accumulator int-4? ] if and
    [ accumulator bad-simd-vector ] unless ;
:: check-bfloat-accumulate ( a b accumulator -- )
    a bfloat-8? b bfloat-8? and accumulator float-4? and
    [ accumulator bad-simd-vector ] unless ;
PRIVATE>

M: simd-128 vdot4+ 3dup check-integer-accumulate (vdot4+) ;
M: simd-128 vmatmul2x8+ 3dup check-integer-accumulate (vmatmul2x8+) ;
M: simd-128 vbdot2+ 3dup check-bfloat-accumulate (vbdot2+) ;
M: simd-128 vbmatmul2x4+ 3dup check-bfloat-accumulate (vbmatmul2x4+) ;

M:: object half-binary ( a b op -- result )
    a b op {
        { "+" [ [ + ] 2map ] }
        { "-" [ [ - ] 2map ] }
        { "*" [ [ * ] 2map ] }
        { "/" [ [ /f ] 2map ] }
        { "min" [ [ min-vector-lane ] 2map ] }
        { "max" [ [ max-vector-lane ] 2map ] }
        { "=" [ [ = -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
        { "<" [ [ < -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
        { "<=" [ [ <= -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
        { ">" [ [ > -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
        { ">=" [ [ >= -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
        { "unordered" [ [ unordered? -1 0 ? ] ushort-8 new 2map-as half-8-cast ] }
    } case ;
M: object half-fma [ half-fma-value ] 3map ;
M: object half-sqrt [ fsqrt ] map ;
M: object pack-half [ >array ] bi@ append >half-8 ;
M: object pack-bfloat [ >array ] bi@ append >bfloat-8 ;

M: half-8 v+ "+" half-binary ;
M: half-8 v- "-" half-binary ;
M: half-8 v* "*" half-binary ;
M: half-8 v/ "/" half-binary ;
M: half-8 vfma half-fma ;
M: half-8 vsqrt half-sqrt ;
M: half-8 vmin "min" half-binary ;
M: half-8 vmax "max" half-binary ;
M: half-8 v= "=" half-binary ;
M: half-8 v< "<" half-binary ;
M: half-8 v<= "<=" half-binary ;
M: half-8 v> ">" half-binary ;
M: half-8 v>= ">=" half-binary ;
M: half-8 vunordered? "unordered" half-binary ;
M: half-8 vs+ v+ ;
M: half-8 vs- v- ;
M: half-8 vs* v* ;
M: bfloat-8 vs+ v+ ;
M: bfloat-8 vs- v- ;
M: bfloat-8 vs* v* ;
M: bfloat-8 vsqrt [ fsqrt float>bits bits>float ] map ;

! Ordinary BF16 arithmetic rounds in binary32 before storage as BF16.
M: bfloat-8 v+ [ + float>bits bits>float ] 2map ;
M: bfloat-8 v- [ - float>bits bits>float ] 2map ;
M: bfloat-8 v* [ * float>bits bits>float ] 2map ;
M: bfloat-8 v/ [ /f float>bits bits>float ] 2map ;
M: bfloat-8 vfma [ ffmaf ] 3map ;

: v>half ( lo hi -- result ) pack-half ;
: v>bfloat ( lo hi -- result ) pack-bfloat ;

cpu arm.64? [ "math.vectors.simd.extensions.arm.64" require ] when
