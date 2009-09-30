! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators classes math layouts
sequences math.vectors.simd.intrinsics
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.simplify

! Return value of f means we didn't simplify.
GENERIC: simplify* ( expr -- vn/expr/f )

M: copy-expr simplify* src>> ;

: simplify-unbox-alien ( expr -- vn/expr/f )
    src>> vn>expr dup box-alien-expr? [ src>> ] [ drop f ] if ;

M: unbox-alien-expr simplify* simplify-unbox-alien ;

M: unbox-any-c-ptr-expr simplify* simplify-unbox-alien ;

: expr-zero? ( expr -- ? ) T{ constant-expr f 0 } = ; inline

: expr-one? ( expr -- ? ) T{ constant-expr f 1 } = ; inline

: expr-neg-one? ( expr -- ? ) T{ constant-expr f -1 } = ; inline

: >unary-expr< ( expr -- in ) src>> vn>expr ; inline

M: neg-expr simplify*
    >unary-expr< {
        { [ dup neg-expr? ] [ src>> ] }
        [ drop f ]
    } cond ;

M: not-expr simplify*
    >unary-expr< {
        { [ dup not-expr? ] [ src>> ] }
        [ drop f ]
    } cond ;

: >binary-expr< ( expr -- in1 in2 )
    [ src1>> vn>expr ] [ src2>> vn>expr ] bi ; inline

: simplify-add ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: add-expr simplify* simplify-add ;
M: add-imm-expr simplify* simplify-add ;

: simplify-sub ( expr -- vn/expr/f )
    >binary-expr< {
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: sub-expr simplify* simplify-sub ;
M: sub-imm-expr simplify* simplify-sub ;

: simplify-mul ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-one? ] [ drop ] }
        { [ dup expr-one? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: mul-expr simplify* simplify-mul ;
M: mul-imm-expr simplify* simplify-mul ;

: simplify-and ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup eq? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: and-expr simplify* simplify-and ;
M: and-imm-expr simplify* simplify-and ;

: simplify-or ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup eq? ] [ drop ] }
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: or-expr simplify* simplify-or ;
M: or-imm-expr simplify* simplify-or ;

: simplify-xor ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: xor-expr simplify* simplify-xor ;
M: xor-imm-expr simplify* simplify-xor ;

: useless-shr? ( in1 in2 -- ? )
    over shl-imm-expr?
    [ [ src2>> ] [ expr>vn ] bi* = ] [ 2drop f ] if ; inline

: simplify-shr ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup useless-shr? ] [ drop src1>> ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: shr-expr simplify* simplify-shr ;
M: shr-imm-expr simplify* simplify-shr ;

: simplify-shl ( expr -- vn/expr/f )
    >binary-expr< {
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: shl-expr simplify* simplify-shl ;
M: shl-imm-expr simplify* simplify-shl ;

M: box-displaced-alien-expr simplify*
    [ base>> ] [ displacement>> ] bi {
        { [ dup vn>expr expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ;

M: scalar>vector-expr simplify*
    src>> vn>expr {
        { [ dup vector>scalar-expr? ] [ src>> ] }
        [ drop f ]
    } cond ;

M: shuffle-vector-expr simplify*
    [ src>> ] [ shuffle>> ] [ rep>> rep-components iota ] tri
    sequence= [ drop f ] unless ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup integer? ] [ nip ] }
    } cond ;

: number-values ( insn -- )
    [ >expr simplify ] [ dst>> ] bi set-vn ;
