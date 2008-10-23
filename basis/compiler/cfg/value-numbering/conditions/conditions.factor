! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences layouts accessors combinators
compiler.cfg.instructions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.liveness
compiler.cfg.value-numbering ;
IN: compiler.cfg.value-numbering.conditions

! The CFG builder produces naive code for the following code
! sequence:
!
! fixnum< [ ... ] [ ... ] if
!
! The fixnum< comparison generates a boolean, which is then
! tested against f.
!
! Using value numbering, we optimize the comparison of a boolean
! against f where the boolean is the result of comparison.

: ##branch-t? ( insn -- ? )
    [ cc>> cc/= eq? ] [ src2>> \ f tag-number eq? ] bi and ; inline

: of-boolean? ( insn -- expr/f ? )
    src1>> vreg>expr dup compare-expr? ; inline

: eliminate-boolean ( insn -- expr/f )
    dup ##branch-t? [
        of-boolean? [ drop f ] unless
    ] [ drop f ] if ; inline

M: ##compare-imm-branch number-values
    dup eliminate-boolean [
        [ in1>> live-vn ] [ in2>> live-vn ] bi
    ] [ call-next-method ] ?if ;
 
: >compare-expr< [ in1>> vn>vreg ] [ in2>> vn>vreg ] [ cc>> ] tri ; inline
: >compare-imm-expr< [ in1>> vn>vreg ] [ in2>> vn>constant ] [ cc>> ] tri ; inline

M: ##compare-imm-branch eliminate
    dup eliminate-boolean [
        dup op>> {
            { \ ##compare [ >compare-expr< f \ ##compare-branch boa ] }
            { \ ##compare-imm [ >compare-imm-expr< f \ ##compare-imm-branch boa ] }
            { \ ##compare-float [ >compare-expr< f \ ##compare-float-branch boa ] }
        } case
    ] [ call-next-method ] ?if ;
