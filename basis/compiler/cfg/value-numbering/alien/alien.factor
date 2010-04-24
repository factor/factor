! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit fry
kernel make math sequences
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

! Fuse ##add-imm into ##load-memory(-imm) and ##store-memory(-imm)
! just update the offset in the instruction
: fuse-base-offset? ( insn -- ? )
    base>> vreg>expr add-imm-expr? ;

: fuse-base-offset ( insn -- insn' )
    dup base>> vreg>expr
    [ src1>> vn>vreg ] [ src2>> vn>integer ] bi
    [ >>base ] [ '[ _ + ] change-offset ] bi* ;

! Fuse ##add-imm into ##load-memory and ##store-memory
! just update the offset in the instruction
: fuse-displacement-offset? ( insn -- ? )
    { [ scale>> 0 = ] [ displacement>> vreg>expr add-imm-expr? ] } 1&& ;

: fuse-displacement-offset ( insn -- insn' )
    dup displacement>> vreg>expr
    [ src1>> vn>vreg ] [ src2>> vn>integer ] bi
    [ >>displacement ] [ '[ _ + ] change-offset ] bi* ;

! Fuse ##add into ##load-memory-imm and ##store-memory-imm
! construct a new ##load-memory or ##store-memory with the
! ##add's operand as the displacement
: fuse-displacement? ( insn -- ? )
    base>> vreg>expr add-expr? ;

GENERIC: alien-insn-value ( insn -- value )

M: ##load-memory-imm alien-insn-value dst>> ;
M: ##store-memory-imm alien-insn-value src>> ;

GENERIC: new-alien-insn ( value base displacement scale offset rep c-type insn -- insn )

M: ##load-memory-imm new-alien-insn drop \ ##load-memory new-insn ;
M: ##store-memory-imm new-alien-insn drop \ ##store-memory new-insn ;

: fuse-displacement ( insn -- insn' )
    {
        [ alien-insn-value ]
        [ base>> vreg>expr [ src1>> vn>vreg ] [ src2>> vn>vreg ] bi ]
        [ drop 0 ]
        [ offset>> ]
        [ rep>> ]
        [ c-type>> ]
        [ ]
    } cleave new-alien-insn ;

! Fuse ##shl-imm into ##load-memory or ##store-memory
: scale-expr? ( expr -- ? )
    { [ shl-imm-expr? ] [ src2>> vn>integer { 1 2 3 } member? ] } 1&& ;

: fuse-scale? ( insn -- ? )
    { [ scale>> 0 = ] [ displacement>> vreg>expr scale-expr? ] } 1&& ;

: fuse-scale ( insn -- insn' )
    dup displacement>> vreg>expr
    [ src1>> vn>vreg ] [ src2>> vn>integer ] bi
    [ >>displacement ] [ >>scale ] bi* ;

: rewrite-memory-op ( insn -- insn/f )
    {
        { [ dup fuse-base-offset? ] [ fuse-base-offset ] }
        { [ dup fuse-displacement-offset? ] [ fuse-displacement-offset ] }
        { [ dup fuse-scale? ] [ fuse-scale ] }
        [ drop f ]
    } cond ;

: rewrite-memory-imm-op ( insn -- insn/f )
    {
        { [ dup fuse-base-offset? ] [ fuse-base-offset ] }
        { [ dup fuse-displacement? ] [ fuse-displacement ] }
        [ drop f ]
    } cond ;

M: ##load-memory rewrite rewrite-memory-op ;
M: ##load-memory-imm rewrite rewrite-memory-imm-op ;
M: ##store-memory rewrite rewrite-memory-op ;
M: ##store-memory-imm rewrite rewrite-memory-imm-op ;
