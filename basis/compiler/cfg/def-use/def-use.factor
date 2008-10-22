! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel compiler.cfg.instructions
compiler.cfg.instructions.syntax ;
IN: compiler.cfg.def-use

GENERIC: defs-vregs ( insn -- seq )
GENERIC: uses-vregs ( insn -- seq )

: dst/tmp-vregs ( insn -- seq ) [ dst>> ] [ temp>> ] bi 2array ;
M: ##flushable defs-vregs dst>> 1array ;
M: ##write-barrier defs-vregs [ card#>> ] [ table>> ] bi 2array ;
M: ##unary/temp defs-vregs dst/tmp-vregs ;
M: ##allot defs-vregs dst/tmp-vregs ;
M: ##dispatch defs-vregs temp>> 1array ;
M: ##slot defs-vregs [ dst>> ] [ temp>> ] bi 2array ;
M: ##set-slot defs-vregs temp>> 1array ;
M: insn defs-vregs drop f ;

M: ##unary uses-vregs src>> 1array ;
M: ##binary uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##binary-imm uses-vregs src1>> 1array ;
M: ##effect uses-vregs src>> 1array ;
M: ##slot uses-vregs [ obj>> ] [ slot>> ] bi 2array ;
M: ##slot-imm uses-vregs obj>> 1array ;
M: ##set-slot uses-vregs [ src>> ] [ obj>> ] [ slot>> ] tri 3array ;
M: ##set-slot-imm uses-vregs [ src>> ] [ obj>> ] bi 2array ;
M: ##conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: ##compare-imm-branch uses-vregs src1>> 1array ;
M: ##dispatch uses-vregs src>> 1array ;
M: ##alien-getter uses-vregs src>> 1array ;
M: ##alien-setter uses-vregs [ src>> ] [ value>> ] bi 2array ;
M: _conditional-branch uses-vregs [ src1>> ] [ src2>> ] bi 2array ;
M: _compare-imm-branch uses-vregs src1>> 1array ;
M: insn uses-vregs drop f ;
