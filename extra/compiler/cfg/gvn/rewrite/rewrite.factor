! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit kernel
layouts math cpu.architecture
compiler.cfg.instructions
compiler.cfg.gvn.graph ;
IN: compiler.cfg.gvn.rewrite

! Outputs f to mean no change
GENERIC: rewrite ( insn -- insn/f )

M: insn rewrite drop f ;

! Utilities
GENERIC: insn>integer ( insn -- n )

M: ##load-integer insn>integer val>> ;

: vreg>integer ( vreg -- n ) vreg>insn insn>integer ; inline

: vreg-immediate-arithmetic? ( vreg -- ? )
    vreg>insn {
        [ ##load-integer? ]
        [ val>> immediate-arithmetic? ]
    } 1&& ;

: vreg-immediate-bitwise? ( vreg -- ? )
    vreg>insn {
        [ ##load-integer? ]
        [ val>> immediate-bitwise? ]
    } 1&& ;

UNION: literal-insn ##load-integer ##load-reference ;

GENERIC: insn>literal ( insn -- n )

M: ##load-integer insn>literal val>> >fixnum ;

M: ##load-reference insn>literal obj>> ;

: vreg>literal ( vreg -- n ) vreg>insn insn>literal ; inline

: vreg-immediate-comparand? ( vreg -- ? )
    vreg>insn {
        { [ dup ##load-integer? ] [ val>> tag-fixnum immediate-comparand? ] }
        { [ dup ##load-reference? ] [ obj>> immediate-comparand? ] }
        [ drop f ]
    } cond ;
