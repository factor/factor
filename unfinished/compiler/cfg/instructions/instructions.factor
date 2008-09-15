! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays kernel sequences namespaces
math compiler.cfg.registers compiler.cfg.instructions.syntax ;
IN: compiler.cfg.instructions

! Virtual CPU instructions, used by CFG and machine IRs

TUPLE: %cond-branch < insn src ;
TUPLE: %unary < insn dst src ;
TUPLE: %nullary < insn dst ;

! Stack operations
INSN: %load-literal < %nullary obj ;
INSN: %peek < %nullary loc ;
INSN: %replace src loc ;
INSN: %inc-d n ;
INSN: %inc-r n ;

! Calling convention
INSN: %return ;

! Subroutine calls
INSN: %call word ;
INSN: %jump word ;
INSN: %intrinsic quot regs ;

! Jump tables
INSN: %dispatch-label label ;
INSN: %dispatch ;

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

GENERIC: defs-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: %nullary defs-vregs dst>> >vreg 1array ;
M: %unary defs-vregs dst>> >vreg 1array ;
M: insn defs-vregs drop f ;

M: %replace uses-vregs src>> >vreg 1array ;
M: %unary uses-vregs src>> >vreg 1array ;
M: insn uses-vregs drop f ;

! M: %intrinsic uses-vregs vregs>> values ;

! Instructions used by CFG IR only.
INSN: %prologue ;
INSN: %epilogue ;
INSN: %frame-required n ;

INSN: %branch ;
INSN: %branch-f < %cond-branch ;
INSN: %branch-t < %cond-branch ;
INSN: %if-intrinsic quot vregs ;
INSN: %boolean-intrinsic quot vregs dst ;

M: %cond-branch uses-vregs src>> 1array ;

! M: %if-intrinsic uses-vregs vregs>> values ;

M: %boolean-intrinsic defs-vregs dst>> 1array ;

! M: %boolean-intrinsic uses-vregs
!     [ vregs>> values ] [ out>> ] bi suffix ;

! Instructions used by machine IR only.
INSN: _prologue n ;
INSN: _epilogue n ;

TUPLE: label id ;

INSN: _label label ;

: <label> ( -- label ) \ <label> counter label boa ;
: define-label ( name -- ) <label> swap set ;

: resolve-label ( label/name -- )
    dup label? [ get ] unless _label ;

TUPLE: _cond-branch < insn src label ;

INSN: _branch label ;
INSN: _branch-f < _cond-branch ;
INSN: _branch-t < _cond-branch ;
INSN: _if-intrinsic label quot vregs ;

M: _cond-branch uses-vregs src>> >vreg 1array ;
! M: _if-intrinsic uses-vregs vregs>> values ;

INSN: _spill src n ;
INSN: _reload dst n ;
