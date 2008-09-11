! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors arrays namespaces kernel math
sequences compiler.instructions compiler.instructions.syntax ;
IN: compiler.machine

! Machine representation. Flat list of instructions, all
! registers allocated, with labels and jumps.

INSN: _prologue n ;
INSN: _epilogue n ;

INSN: _label label ;

: <label> ( -- label ) \ <label> counter ;
: define-label ( name -- ) <label> swap set ;
: resolve-label ( label/name -- ) dup integer? [ get ] unless _label ;

TUPLE: _cond-branch vreg label ;

INSN: _branch label ;
INSN: _branch-f < _cond-branch ;
INSN: _branch-t < _cond-branch ;
INSN: _if-intrinsic label quot vregs ;

M: _cond-branch uses-vregs vreg>> 1array ;
M: _if-intrinsic uses-vregs vregs>> values ;
