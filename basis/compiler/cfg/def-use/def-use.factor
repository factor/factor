! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel compiler.cfg.instructions ;
IN: compiler.cfg.def-use

GENERIC: defs-vregs ( insn -- seq )
GENERIC: temp-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

M: ##flushable defs-vregs dst>> 1array ;
M: ##unary/temp defs-vregs dst>> 1array ;
M: ##allot defs-vregs dst>> 1array ;
M: ##slot defs-vregs dst>> 1array ;
M: ##set-slot defs-vregs temp>> 1array ;
M: ##string-nth defs-vregs dst>> 1array ;
M: ##compare defs-vregs dst>> 1array ;
M: ##compare-imm defs-vregs dst>> 1array ;
M: ##compare-float defs-vregs dst>> 1array ;
M: insn defs-vregs drop f ;

M: ##write-barrier temp-vregs [ card#>> ] [ table>> ] bi 2array ;
M: ##unary/temp temp-vregs temp>> 1array ;
M: ##allot temp-vregs temp>> 1array ;
M: ##dispatch temp-vregs temp>> 1array ;
M: ##slot temp-vregs temp>> 1array ;
M: ##set-slot temp-vregs temp>> 1array ;
M: ##string-nth temp-vregs temp>> 1array ;
M: ##set-string-nth-fast temp-vregs temp>> 1array ;
M: ##compare temp-vregs temp>> 1array ;
M: ##compare-imm temp-vregs temp>> 1array ;
M: ##compare-float temp-vregs temp>> 1array ;
M: ##fixnum-mul temp-vregs [ temp1>> ] [ temp2>> ] bi 2array ;
M: ##fixnum-mul-tail temp-vregs [ temp1>> ] [ temp2>> ] bi 2array ;
M: _dispatch temp-vregs temp>> 1array ;
M: insn temp-vregs drop f ;

M: ##unary uses-vregs src>> 1array ;
M: ##binary uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##binary-imm uses-vregs src1>> 1array ;
M: ##effect uses-vregs src>> 1array ;
M: ##slot uses-vregs [ obj>> ] [ slot>> ] bi 2array ;
M: ##slot-imm uses-vregs obj>> 1array ;
M: ##set-slot uses-vregs [ src>> ] [ obj>> ] [ slot>> ] tri 3array ;
M: ##set-slot-imm uses-vregs [ src>> ] [ obj>> ] bi 2array ;
M: ##string-nth uses-vregs [ obj>> ] [ index>> ] bi 2array ;
M: ##set-string-nth-fast uses-vregs [ src>> ] [ obj>> ] [ index>> ] tri 3array ;
M: ##conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##compare-imm-branch uses-vregs src1>> 1array ;
M: ##dispatch uses-vregs src>> 1array ;
M: ##alien-getter uses-vregs src>> 1array ;
M: ##alien-setter uses-vregs [ src>> ] [ value>> ] bi 2array ;
M: ##fixnum-overflow uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##phi uses-vregs inputs>> ;
M: _conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: _compare-imm-branch uses-vregs src1>> 1array ;
M: _dispatch uses-vregs src>> 1array ;
M: _gc uses-vregs live-in>> ;
M: insn uses-vregs drop f ;

! Instructions that use vregs
UNION: vreg-insn
##flushable
##write-barrier
##dispatch
##effect
##fixnum-overflow
##conditional-branch
##compare-imm-branch
_conditional-branch
_compare-imm-branch
_dispatch
_gc ;
