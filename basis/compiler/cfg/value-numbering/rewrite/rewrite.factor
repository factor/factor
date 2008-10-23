! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences layouts accessors combinators namespaces
math
compiler.cfg.instructions
compiler.cfg.instructions.syntax
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions ;
IN: compiler.cfg.value-numbering.rewrite

GENERIC: rewrite ( insn -- insn' )

: ##branch-t? ( insn -- ? )
    [ cc>> cc/= eq? ] [ src2>> \ f tag-number eq? ] bi and ; inline

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
        { \ ##compare [ >compare-expr< f \ ##compare-branch boa ] }
        { \ ##compare-imm [ >compare-imm-expr< f \ ##compare-imm-branch boa ] }
        { \ ##compare-float [ >compare-expr< f \ ##compare-float-branch boa ] }
    } case ;

: tag-fixnum-expr? ( expr -- ? )
    dup op>> \ ##shl-imm eq?
    [ in2>> vn>expr value>> tag-bits get = ] [ drop f ] if ;

: rewrite-tagged-comparison? ( insn -- ? )
    #! Are we comparing two tagged fixnums? Then untag them.
    [ src1>> vreg>expr tag-fixnum-expr? ]
    [ src2>> tag-mask get bitand 0 = ]
    bi and ; inline

: rewrite-tagged-comparison ( insn -- insn' )
    [ src1>> vreg>expr in1>> vn>vreg ]
    [ src2>> tag-bits get neg shift ]
    [ cc>> ]
    tri
    f \ ##compare-imm-branch boa ;

M: ##compare-imm-branch rewrite
    dup rewrite-boolean-comparison? [ rewrite-boolean-comparison ] when
    dup rewrite-tagged-comparison? [ rewrite-tagged-comparison ] when ;

M: insn rewrite ;
