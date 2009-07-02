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
        { [ 2dup eq? ] [ 2drop T{ constant-expr f f 0 } ] }
        { [ dup expr-zero? ] [ drop ] }
        [ 2drop f ]
    } cond ; inline

: useless-shift? ( in1 in2 -- ? )
    over op>> \ ##shl-imm eq?
    [ [ in2>> ] [ expr>vn ] bi* = ] [ 2drop f ] if ; inline

: simplify-shift ( expr -- vn/expr/f )
    >binary-expr<
    2dup useless-shift? [ drop in1>> ] [ 2drop f ] if ; inline

M: binary-expr simplify*
    dup op>> {
        { \ ##add [ simplify-add ] }
        { \ ##add-imm [ simplify-add ] }
        { \ ##sub [ simplify-sub ] }
        { \ ##sub-imm [ simplify-sub ] }
        { \ ##shr-imm [ simplify-shift ] }
        { \ ##sar-imm [ simplify-shift ] }
        [ 2drop f ]
    } case ;

M: expr simplify* drop f ;

: simplify ( expr -- vn )
    dup simplify* {
        { [ dup not ] [ drop expr>vn ] }
        { [ dup expr? ] [ expr>vn nip ] }
        { [ dup integer? ] [ nip ] }
    } cond ;

GENERIC: number-values ( insn -- )

M: ##flushable number-values [ >expr simplify ] [ dst>> ] bi set-vn ;
M: insn number-values drop ;
