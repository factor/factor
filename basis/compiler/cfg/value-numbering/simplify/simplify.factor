! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors combinators classes math layouts
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions locals ;
IN: compiler.cfg.value-numbering.simplify

! Return value of f means we didn't simplify.
GENERIC: simplify* ( expr -- vn/expr/f )

: simplify-unbox ( in boxer -- vn/expr/f )
    over op>> eq? [ in>> ] [ drop f ] if ; inline

: simplify-unbox-float ( in -- vn/expr/f )
    \ ##box-float simplify-unbox ; inline

: simplify-unbox-alien ( in -- vn/expr/f )
    \ ##box-alien simplify-unbox ; inline

M: unary-expr simplify*
    #! Note the copy propagation: a copy always simplifies to
    #! its source VN.
    [ in>> vn>expr ] [ op>> ] bi {
        { \ ##copy [ ] }
        { \ ##copy-float [ ] }
        { \ ##unbox-float [ simplify-unbox-float ] }
        { \ ##unbox-alien [ simplify-unbox-alien ] }
        { \ ##unbox-any-c-ptr [ simplify-unbox-alien ] }
        [ 2drop f ]
    } case ;

: expr-zero? ( expr -- ? ) T{ constant-expr f f 0 } = ; inline

: expr-one? ( expr -- ? ) T{ constant-expr f f 1 } = ; inline

: >binary-expr< ( expr -- in1 in2 )
    [ in1>> vn>expr ] [ in2>> vn>expr ] bi ; inline

: simplify-add ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-sub ( expr -- vn/expr/f )
    >binary-expr< {
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-mul ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-one? ] [ drop ] }
        { [ dup expr-one? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-and ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup eq? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-or ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup eq? ] [ drop ] }
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-xor ( expr -- vn/expr/f )
    >binary-expr< {
        { [ over expr-zero? ] [ nip ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: useless-shr? ( in1 in2 -- ? )
    over op>> \ ##shl-imm eq?
    [ [ in2>> ] [ expr>vn ] bi* = ] [ 2drop f ] if ; inline

: simplify-shr ( expr -- vn/expr/f )
    >binary-expr< {
        { [ 2dup useless-shr? ] [ drop in1>> ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: simplify-shl ( expr -- vn/expr/f )
    >binary-expr< {
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

M: binary-expr simplify*
    dup op>> {
        { \ ##add [ simplify-add ] }
        { \ ##add-imm [ simplify-add ] }
        { \ ##sub [ simplify-sub ] }
        { \ ##sub-imm [ simplify-sub ] }
        { \ ##mul [ simplify-mul ] }
        { \ ##mul-imm [ simplify-mul ] }
        { \ ##and [ simplify-and ] }
        { \ ##and-imm [ simplify-and ] }
        { \ ##or [ simplify-or ] }
        { \ ##or-imm [ simplify-or ] }
        { \ ##xor [ simplify-xor ] }
        { \ ##xor-imm [ simplify-xor ] }
        { \ ##shr [ simplify-shr ] }
        { \ ##shr-imm [ simplify-shr ] }
        { \ ##sar [ simplify-shr ] }
        { \ ##sar-imm [ simplify-shr ] }
        { \ ##shl [ simplify-shl ] }
        { \ ##shl-imm [ simplify-shl ] }
        [ 2drop f ]
    } case ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup integer? ] [ nip ] }
    } cond ;

: number-values ( insn -- )
    [ >expr simplify ] [ dst>> ] bi set-vn ;
