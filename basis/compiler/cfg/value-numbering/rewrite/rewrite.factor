! Copyright (C) 2008, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors locals combinators combinators.short-circuit arrays
fry kernel layouts math namespaces sequences cpu.architecture
math.bitwise
compiler.cfg.hats
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.simplify ;
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

: tagged>constant ( n -- n' )
    tag-bits get neg shift ; inline

: (rewrite-tagged-comparison) ( insn -- src1 src2 cc )
    [ src1>> vreg>expr in1>> vn>vreg ]
    [ src2>> tagged>constant ]
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

:: >compare-imm ( insn swap? -- insn' )
    insn dst>>
    insn src1>>
    insn src2>> swap? [ swap ] when vreg>constant
    insn cc>> swap? [ swap-cc ] when
    i \ ##compare-imm new-insn ; inline

: vreg-small-constant? ( vreg -- ? )
    vreg>expr {
        [ constant-expr? ]
        [ value>> small-enough? ]
    } 1&& ;

M: ##compare rewrite
    dup [ src1>> ] [ src2>> ] bi
    [ vreg-small-constant? ] bi@ 2array {
        { { f t } [ f >compare-imm ] }
        { { t f } [ t >compare-imm ] }
        [ drop ]
    } case ;

:: >compare-imm-branch ( insn swap? -- insn' )
    insn src1>>
    insn src2>> swap? [ swap ] when vreg>constant
    insn cc>> swap? [ swap-cc ] when
    \ ##compare-imm-branch new-insn ; inline

M: ##compare-branch rewrite
    dup [ src1>> ] [ src2>> ] bi
    [ vreg-small-constant? ] bi@ 2array {
        { { f t } [ f >compare-imm-branch ] }
        { { t f } [ t >compare-imm-branch ] }
        [ drop ]
    } case ;

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

: constant-fold ( insn -- insn' )
    dup dst>> vreg>expr dup constant-expr? [
        [ dst>> ] [ value>> ] bi* \ ##load-immediate new-insn
        dup number-values
    ] [
        drop
    ] if ;

: (new-imm-insn) ( insn dst src1 n op -- new-insn/insn )
    [ cell-bits bits ] dip over small-enough? [
        new-insn dup number-values nip
    ] [
        2drop 2drop
    ] if constant-fold ; inline

: new-imm-insn ( insn dst src n op -- n' op' )
    2dup [ sgn ] dip 2array
    {
        { { -1 ##add-imm } [ drop neg \ ##sub-imm (new-imm-insn) ] }
        { { -1 ##sub-imm } [ drop neg \ ##add-imm (new-imm-insn) ] }
        [ drop (new-imm-insn) ]
    } case ; inline

: combine-imm? ( insn op -- ? )
    [ src1>> vreg>expr op>> ] dip = ;

: (combine-imm) ( insn quot op -- insn )
    [
        {
            [ ]
            [ dst>> ]
            [ src1>> vreg>expr [ in1>> vn>vreg ] [ in2>> vn>constant ] bi ]
            [ src2>> ]
        } cleave
    ] [ call ] [ ] tri* new-imm-insn ; inline

:: combine-imm ( insn quot op -- insn )
    insn op combine-imm? [
        insn quot op (combine-imm)
    ] [
        insn
    ] if ; inline

M: ##add-imm rewrite
    {
        { [ dup \ ##add-imm combine-imm? ] [ [ + ] \ ##add-imm (combine-imm) ] }
        { [ dup \ ##sub-imm combine-imm? ] [ [ - ] \ ##sub-imm (combine-imm) ] }
        [ ]
    } cond ;

M: ##sub-imm rewrite
    {
        { [ dup \ ##add-imm combine-imm? ] [ [ - ] \ ##add-imm (combine-imm) ] }
        { [ dup \ ##sub-imm combine-imm? ] [ [ + ] \ ##sub-imm (combine-imm) ] }
        [ ]
    } cond ;

M: ##mul-imm rewrite
    dup src2>> dup power-of-2? [
        [ [ dst>> ] [ src1>> ] bi ] [ log2 ] bi* \ ##shl-imm new-insn
        dup number-values
    ] [
        drop [ * ] \ ##mul-imm combine-imm
    ] if ;

M: ##and-imm rewrite [ bitand ] \ ##and-imm combine-imm ;

M: ##or-imm rewrite [ bitor ] \ ##or-imm combine-imm ;

M: ##xor-imm rewrite [ bitxor ] \ ##xor-imm combine-imm ;

: new-arithmetic ( obj op -- )
    [
        [ dst>> ]
        [ src1>> ]
        [ src2>> vreg>constant ] tri
    ] dip new-insn dup number-values ; inline

: rewrite-arithmetic ( insn op -- ? )
    over src2>> vreg-small-constant? [
        new-arithmetic constant-fold
    ] [
        drop
    ] if ; inline

M: ##add rewrite \ ##add-imm rewrite-arithmetic ;

M: ##sub rewrite \ ##sub-imm rewrite-arithmetic ;
