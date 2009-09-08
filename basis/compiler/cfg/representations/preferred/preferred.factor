! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences arrays fry namespaces
cpu.architecture compiler.cfg.utilities compiler.cfg compiler.cfg.rpo
compiler.cfg.instructions compiler.cfg.def-use ;
IN: compiler.cfg.representations.preferred

GENERIC: defs-vreg-rep ( insn -- rep/f )
GENERIC: temp-vreg-reps ( insn -- reps )
GENERIC: uses-vreg-reps ( insn -- reps )

M: ##flushable defs-vreg-rep drop int-rep ;
M: ##copy defs-vreg-rep rep>> ;
M: output-float-insn defs-vreg-rep drop double-float-rep ;
M: ##fixnum-overflow defs-vreg-rep drop int-rep ;
M: _fixnum-overflow defs-vreg-rep drop int-rep ;
M: ##phi defs-vreg-rep drop "##phi must be special-cased" throw ;
M: insn defs-vreg-rep drop f ;

M: ##write-barrier temp-vreg-reps drop { int-rep int-rep } ;
M: ##unary/temp temp-vreg-reps drop { int-rep } ;
M: ##allot temp-vreg-reps drop { int-rep } ;
M: ##dispatch temp-vreg-reps drop { int-rep } ;
M: ##slot temp-vreg-reps drop { int-rep } ;
M: ##set-slot temp-vreg-reps drop { int-rep } ;
M: ##string-nth temp-vreg-reps drop { int-rep } ;
M: ##set-string-nth-fast temp-vreg-reps drop { int-rep } ;
M: ##box-displaced-alien temp-vreg-reps drop { int-rep int-rep } ;
M: ##compare temp-vreg-reps drop { int-rep } ;
M: ##compare-imm temp-vreg-reps drop { int-rep } ;
M: ##compare-float temp-vreg-reps drop { int-rep } ;
M: ##gc temp-vreg-reps drop { int-rep int-rep } ;
M: _dispatch temp-vreg-reps drop { int-rep } ;
M: insn temp-vreg-reps drop f ;

M: ##copy uses-vreg-reps rep>> 1array ;
M: ##unary uses-vreg-reps drop { int-rep } ;
M: ##unary-float uses-vreg-reps drop { double-float-rep } ;
M: ##binary uses-vreg-reps drop { int-rep int-rep } ;
M: ##binary-imm uses-vreg-reps drop { int-rep } ;
M: ##binary-float uses-vreg-reps drop { double-float-rep double-float-rep } ;
M: ##effect uses-vreg-reps drop { int-rep } ;
M: ##slot uses-vreg-reps drop { int-rep int-rep } ;
M: ##slot-imm uses-vreg-reps drop { int-rep } ;
M: ##set-slot uses-vreg-reps drop { int-rep int-rep int-rep } ;
M: ##set-slot-imm uses-vreg-reps drop { int-rep int-rep } ;
M: ##string-nth uses-vreg-reps drop { int-rep int-rep } ;
M: ##set-string-nth-fast uses-vreg-reps drop { int-rep int-rep int-rep } ;
M: ##compare-branch uses-vreg-reps drop { int-rep int-rep } ;
M: ##compare-imm-branch uses-vreg-reps drop { int-rep } ;
M: ##compare-float-branch uses-vreg-reps drop { double-float-rep double-float-rep } ;
M: ##dispatch uses-vreg-reps drop { int-rep } ;
M: ##alien-getter uses-vreg-reps drop { int-rep } ;
M: ##alien-setter uses-vreg-reps drop { int-rep int-rep } ;
M: ##set-alien-float uses-vreg-reps drop { int-rep double-float-rep } ;
M: ##set-alien-double uses-vreg-reps drop { int-rep double-float-rep } ;
M: ##fixnum-overflow uses-vreg-reps drop { int-rep int-rep } ;
M: _compare-imm-branch uses-vreg-reps drop { int-rep } ;
M: _compare-branch uses-vreg-reps drop { int-rep int-rep } ;
M: _compare-float-branch uses-vreg-reps drop { double-float-rep double-float-rep } ;
M: _dispatch uses-vreg-reps drop { int-rep } ;
M: ##phi uses-vreg-reps drop "##phi must be special-cased" throw ;
M: insn uses-vreg-reps drop f ;

: each-def-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ defs-vreg ] [ defs-vreg-rep ] bi ] dip with when* ; inline

: each-use-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ uses-vregs ] [ uses-vreg-reps ] bi ] dip 2each ; inline

: each-temp-rep ( insn vreg-quot: ( vreg rep -- ) -- )
    [ [ temp-vregs ] [ temp-vreg-reps ] bi ] dip 2each ; inline

: with-vreg-reps ( cfg vreg-quot: ( vreg rep -- ) -- )
    '[
        [ basic-block set ] [
            [
                _
                [ each-def-rep ]
                [ each-use-rep ]
                [ each-temp-rep ] 2tri
            ] each-non-phi
        ] bi
    ] each-basic-block ; inline
