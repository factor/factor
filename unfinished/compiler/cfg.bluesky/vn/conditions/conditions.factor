! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences layouts accessors compiler.vops
compiler.cfg.vn.graph
compiler.cfg.vn.expressions
compiler.cfg.vn.liveness
compiler.cfg.vn ;
IN: compiler.cfg.vn.conditions

! The CFG generator produces naive code for the following code
! sequence:
!
! fixnum< [ ... ] [ ... ] if
!
! The fixnum< comparison generates a boolean, which is then
! tested against f.
!
! Using value numbering, we optimize the comparison of a boolean
! against f where the boolean is the result of comparison.

: expr-f? ( expr -- ? )
    dup op>> %iconst eq?
    [ value>> \ f tag-number = ] [ drop f ] if ;

: comparison-with-f? ( insn -- expr/f ? )
    #! The expr is a binary-op %icmp or %fcmp.
    dup code>> cc/= eq? [
        in>> vreg>vn vn>expr dup in2>> vn>expr expr-f?
    ] [ drop f f ] if ;

: of-boolean? ( expr -- expr/f ? )
    #! The expr is a binary-op %icmp or %fcmp.
    in1>> vn>expr dup op>> { %%iboolean %%fboolean } memq? ;

: original-comparison ( expr -- in/f code/f )
    [ in>> vn>vreg ] [ code>> ] bi ;

: eliminate-boolean ( insn -- in/f code/f )
    comparison-with-f? [
        of-boolean? [
            original-comparison
        ] [ drop f f ] if
    ] [ drop f f ] if ;

M: cond-branch make-value-node
    #! If the conditional branch is testing the result of an
    #! earlier comparison against f, we only mark as live the
    #! earlier comparison, so DCE will eliminate the boolean.
    dup eliminate-boolean drop swap in>> or live-vreg ;
 
M: cond-branch eliminate
    dup eliminate-boolean dup
    [ [ >>in ] [ >>code ] bi* ] [ 2drop ] if ;
