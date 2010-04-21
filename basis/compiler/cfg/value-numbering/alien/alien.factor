! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel make math
compiler.cfg.hats
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.value-numbering.expressions
compiler.cfg.value-numbering.graph
compiler.cfg.value-numbering.rewrite ;
IN: compiler.cfg.value-numbering.alien

! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 4 1 <class>
! =>
! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 5 3 <class>
! ##add 4 5 2

: rewrite-unbox-displaced-alien ( insn expr -- insns )
    [
        [ dst>> ]
        [ [ base>> vn>vreg ] [ base-class>> ] [ displacement>> vn>vreg ] tri ] bi*
        [ ^^unbox-c-ptr ] dip
        ##add
    ] { } make ;

M: ##unbox-any-c-ptr rewrite
    dup src>> vreg>expr dup box-displaced-alien-expr?
    [ rewrite-unbox-displaced-alien ] [ 2drop f ] if ;

! More efficient addressing for alien intrinsics
: rewrite-alien-addressing ( insn -- insn' )
    dup src>> vreg>expr dup add-imm-expr? [
        [ src1>> vn>vreg ] [ src2>> vn>integer ] bi
        [ >>src ] [ '[ _ + ] change-offset ] bi*
    ] [ 2drop f ] if ;

M: ##alien-unsigned-1 rewrite rewrite-alien-addressing ;
M: ##alien-unsigned-2 rewrite rewrite-alien-addressing ;
M: ##alien-unsigned-4 rewrite rewrite-alien-addressing ;
M: ##alien-signed-1 rewrite rewrite-alien-addressing ;
M: ##alien-signed-2 rewrite rewrite-alien-addressing ;
M: ##alien-signed-4 rewrite rewrite-alien-addressing ;
M: ##alien-float rewrite rewrite-alien-addressing ;
M: ##alien-double rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-1 rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-2 rewrite rewrite-alien-addressing ;
M: ##set-alien-integer-4 rewrite rewrite-alien-addressing ;
M: ##set-alien-float rewrite rewrite-alien-addressing ;
M: ##set-alien-double rewrite rewrite-alien-addressing ;
