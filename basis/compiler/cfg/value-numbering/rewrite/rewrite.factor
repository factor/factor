! Copyright (C) 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
arrays compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.simplify fry kernel layouts math
namespaces sequences cpu.architecture math.bitwise ;
IN: compiler.cfg.value-numbering.rewrite

GENERIC: rewrite ( insn -- insn' )

M: insn rewrite ;

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
    [ src1>> vreg>constant ] tri
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

: (new-imm-insn) ( insn dst src1 n op -- new-insn/insn )
    [ cell-bits bits ] dip over small-enough? [
        new-insn dup number-values nip
    ] [
        2drop 2drop
    ] if ; inline

: new-imm-insn ( insn dst src n op -- n' op' )
    2dup [ sgn ] dip 2array
    {
        { { -1 ##add-imm } [ drop neg \ ##sub-imm (new-imm-insn) ] }
        { { -1 ##sub-imm } [ drop neg \ ##add-imm (new-imm-insn) ] }
        [ drop (new-imm-insn) ]
    } case ; inline

: combine-imm? ( insn op -- ? )
    [ src1>> vreg>expr op>> ] dip = ;

: combine-imm ( insn quot op -- insn )
    [
        {
            [ ]
            [ dst>> ]
            [ src1>> vreg>expr [ in1>> vn>vreg ] [ in2>> vn>constant ] bi ]
            [ src2>> ]
        } cleave
    ] [ call ] [ ] tri* new-imm-insn ; inline

M: ##add-imm rewrite
    {
        { [ dup \ ##add-imm combine-imm? ] [ [ + ] \ ##add-imm combine-imm ] }
        { [ dup \ ##sub-imm combine-imm? ] [ [ - ] \ ##sub-imm combine-imm ] }
        [ ]
    } cond ;

M: ##sub-imm rewrite
    {
        { [ dup \ ##add-imm combine-imm? ] [ [ - ] \ ##add-imm combine-imm ] }
        { [ dup \ ##sub-imm combine-imm? ] [ [ + ] \ ##sub-imm combine-imm ] }
        [ ]
    } cond ;

M: ##mul-imm rewrite
    dup src2>> dup power-of-2? [
        [ [ dst>> ] [ src1>> ] bi ] [ log2 ] bi* \ ##shl-imm new-insn
        dup number-values
    ] [
        drop dup \ ##mul-imm combine-imm?
        [ [ * ] \ ##mul-imm combine-imm ] when
    ] if ;

M: ##and-imm rewrite
    dup \ ##and-imm combine-imm?
    [ [ bitand ] \ ##and-imm combine-imm ] when ;

M: ##or-imm rewrite
    dup \ ##or-imm combine-imm?
    [ [ bitor ] \ ##or-imm combine-imm ] when ;

M: ##xor-imm rewrite
    dup \ ##xor-imm combine-imm?
    [ [ bitxor ] \ ##xor-imm combine-imm ] when ;

: rewrite-add>add-imm? ( insn -- ? )
    src2>> {
        [ vreg>expr constant-expr? ]
        [ vreg>constant small-enough? ]
    } 1&& ;

M: ##add rewrite
    dup rewrite-add>add-imm? [
        [ dst>> ]
        [ src1>> ]
        [ src2>> vreg>constant ] tri \ ##add-imm new-insn
        dup number-values
    ] when ;
