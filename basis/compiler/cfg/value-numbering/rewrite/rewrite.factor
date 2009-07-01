! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.simplify fry kernel layouts math
namespaces sequences ;
IN: compiler.cfg.value-numbering.rewrite

GENERIC: rewrite ( insn -- insn' )

M: ##mul-imm rewrite
    dup src2>> dup power-of-2? [
        [ [ dst>> ] [ src1>> ] bi ] [ log2 ] bi* \ ##shl-imm new-insn
        dup number-values
    ] [ drop ] if ;

: ##branch-t? ( insn -- ? )
    dup ##compare-imm-branch? [
        {
            [ cc>> cc/= eq? ]
            [ src2>> \ f tag-number eq? ]
        } 1&&
    ] [ drop f ] if ; inline

: rewrite-boolean-comparison? ( insn -- ? )
    dup ##branch-t? [
        src1>> vreg>expr compare-expr?
    ] [ drop f ] if ; inline
 
: >compare-expr< ( expr -- in1 in2 cc )
    [ in1>> vn>vreg ] [ in2>> vn>vreg ] [ cc>> ] tri ; inline

: >compare-imm-expr< ( expr -- in1 in2 cc )
    [ in1>> vn>vreg ] [ in2>> vn>constant ] [ cc>> ] tri ; inline

: rewrite-boolean-comparison ( expr -- insn )
    src1>> vreg>expr dup op>> {
        { \ ##compare [ >compare-expr< \ ##compare-branch new-insn ] }
        { \ ##compare-imm [ >compare-imm-expr< \ ##compare-imm-branch new-insn ] }
        { \ ##compare-float [ >compare-expr< \ ##compare-float-branch new-insn ] }
    } case ;

: tag-fixnum-expr? ( expr -- ? )
    dup op>> \ ##shl-imm eq?
    [ in2>> vn>constant tag-bits get = ] [ drop f ] if ;

: rewrite-tagged-comparison? ( insn -- ? )
    #! Are we comparing two tagged fixnums? Then untag them.
    {
        [ src1>> vreg>expr tag-fixnum-expr? ]
        [ src2>> tag-mask get bitand 0 = ]
    } 1&& ; inline

: (rewrite-tagged-comparison) ( insn -- src1 src2 cc )
    [ src1>> vreg>expr in1>> vn>vreg ]
    [ src2>> tag-bits get neg shift ]
    [ cc>> ]
    tri ; inline

GENERIC: rewrite-tagged-comparison ( insn -- insn' )

M: ##compare-imm-branch rewrite-tagged-comparison
    (rewrite-tagged-comparison) \ ##compare-imm-branch new-insn ;

M: ##compare-imm rewrite-tagged-comparison
    [ dst>> ] [ (rewrite-tagged-comparison) ] bi
    i \ ##compare-imm new-insn ;

M: ##compare-imm-branch rewrite
    dup rewrite-boolean-comparison? [ rewrite-boolean-comparison ] when
    dup ##compare-imm-branch? [
        dup rewrite-tagged-comparison? [ rewrite-tagged-comparison ] when
    ] when ;

: flip-comparison? ( insn -- ? )
    dup cc>> cc= eq? [ src1>> vreg>expr constant-expr? ] [ drop f ] if ;

: flip-comparison ( insn -- insn' )
    [ dst>> ]
    [ src2>> ]
    [ src1>> vreg>vn vn>constant ] tri
    cc= i \ ##compare-imm new-insn ;

M: ##compare rewrite
    dup flip-comparison? [
        flip-comparison
        dup number-values
        rewrite
    ] when ;

: rewrite-redundant-comparison? ( insn -- ? )
    {
        [ src1>> vreg>expr compare-expr? ]
        [ src2>> \ f tag-number = ]
        [ cc>> { cc= cc/= } memq? ]
    } 1&& ; inline

: rewrite-redundant-comparison ( insn -- insn' )
    [ cc>> ] [ dst>> ] [ src1>> vreg>expr dup op>> ] tri {
        { \ ##compare [ >compare-expr< i \ ##compare new-insn ] }
        { \ ##compare-imm [ >compare-imm-expr< i \ ##compare-imm new-insn ] }
        { \ ##compare-float [ >compare-expr< i \ ##compare-float new-insn ] }
    } case
    swap cc= eq? [ [ negate-cc ] change-cc ] when ;

M: ##compare-imm rewrite
    dup rewrite-redundant-comparison? [
        rewrite-redundant-comparison
        dup number-values rewrite
    ] when
    dup ##compare-imm? [
        dup rewrite-tagged-comparison? [
            rewrite-tagged-comparison
            dup number-values rewrite
        ] when
    ] when ;

: combine-add-imm? ( insn -- ? )
    {
        [ src1>> vreg>expr op>> \ ##add-imm = ]
        [ src2>> number? ]
    } 1&& ;

: combine-add-imm ( dst src n -- insn )
    [ vreg>expr [ in1>> vn>vreg ] [ in2>> vn>constant ] bi ] dip
    + \ ##add-imm new-insn ;

M: ##add-imm rewrite
    dup combine-add-imm? [
        [ dst>> ] [ src1>> ] [ src2>> ] tri combine-add-imm
        dup number-values
    ] when ;

M: insn rewrite ;
