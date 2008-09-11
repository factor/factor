! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences
compiler.instructions.syntax ;
IN: compiler.instructions

! Virtual CPU instructions, used by CFG and machine IRs

INSN: %cond-branch vreg ;
INSN: %unary dst src ;

! Stack operations
INSN: %peek vreg loc ;
INSN: %replace vreg loc ;
INSN: %inc-d n ;
INSN: %inc-r n ;
INSN: %load-literal obj vreg ;

! Calling convention
INSN: %prologue ;
INSN: %epilogue ;
INSN: %frame-required n ;
INSN: %return ;

! Subroutine calls
INSN: %call word ;
INSN: %jump word ;
INSN: %intrinsic quot vregs ;

! Jump tables
INSN: %dispatch-label label ;
INSN: %dispatch ;

! Unconditional branch to successor (CFG only)
INSN: %branch ;

! Conditional branches (CFG only)
INSN: %branch-f < %cond-branch ;
INSN: %branch-t < %cond-branch ;
INSN: %if-intrinsic quot vregs ;
INSN: %boolean-intrinsic quot vregs out ;

! Boxing and unboxing
INSN: %copy < %unary ;
INSN: %copy-float < %unary ;
INSN: %unbox-float < %unary ;
INSN: %unbox-f < %unary ;
INSN: %unbox-alien < %unary ;
INSN: %unbox-byte-array < %unary ;
INSN: %unbox-any-c-ptr < %unary ;
INSN: %box-float < %unary ;
INSN: %box-alien < %unary ;

INSN: %gc ;

! FFI
INSN: %alien-invoke params ;
INSN: %alien-indirect params ;
INSN: %alien-callback params ;

GENERIC: uses-vregs ( insn -- seq )

M: insn uses-vregs drop f ;
M: %peek uses-vregs vreg>> 1array ;
M: %replace uses-vregs vreg>> 1array ;
M: %load-literal uses-vregs vreg>> 1array ;
M: %cond-branch uses-vregs vreg>> 1array ;
M: %unary uses-vregs [ dst>> ] [ src>> ] bi 2array ;
M: %intrinsic uses-vregs vregs>> values ;
M: %if-intrinsic uses-vregs vregs>> values ;
M: %boolean-intrinsic uses-vregs
    [ vregs>> values ] [ out>> ] bi suffix ;
