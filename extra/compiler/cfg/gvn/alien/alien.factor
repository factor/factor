! Copyright (C) 2010 Slava Pestov, 2011 Alex Vondrak
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.short-circuit
compiler.cfg.gvn.avail compiler.cfg.gvn.graph
compiler.cfg.gvn.math compiler.cfg.gvn.rewrite compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.utilities
cpu.architecture kernel make math namespaces sequences ;
IN: compiler.cfg.gvn.alien

M: ##box-displaced-alien rewrite
    dup displacement>> vreg>insn zero-insn?
    [ [ dst>> ] [ base>> ] bi <copy> ] [ drop f ] if ;

! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 4 1 <class>
! =>
! ##box-displaced-alien f 1 2 3 <class>
! ##unbox-c-ptr 5 3 <class>
! ##add 4 5 2

: rewrite-unbox-alien ( insn box-insn -- insn )
    [ dst>> ] [ src>> ] bi* <copy> ;

! XXX  next-vreg makes vregs>vns change on every iteration
! (hidden in ^^unbox-c-ptr)
: rewrite-unbox-displaced-alien ( insn box-insn -- insns )
    [
        [ dst>> ]
        [ [ base>> ] [ base-class>> ] [ displacement>> ] tri ] bi*
        [ ^^unbox-c-ptr ] dip
        ##add,
    ] { } make ;

: rewrite-unbox-any-c-ptr ( insn -- insn/f )
    dup src>> vreg>insn
    {
        {
            [ dup [ ##box-alien? ] with-available-uses? ]
            [ rewrite-unbox-alien ]
        }
        {
            ! [ dup [ ##box-displaced-alien? ] with-available-uses? ]
            [
                final-iteration? get [
                    dup [ ##box-displaced-alien? ] with-available-uses?
                ] [ f ] if
            ]
            [ rewrite-unbox-displaced-alien ]
        }
        [ 2drop f ]
    } cond ;

M: ##unbox-any-c-ptr rewrite rewrite-unbox-any-c-ptr ;

M: ##unbox-alien rewrite rewrite-unbox-any-c-ptr ;

! Fuse ##add-imm into ##load-memory(-imm) and ##store-memory(-imm)
! just update the offset in the instruction
: fuse-base-offset? ( insn -- ? )
    base>> vreg>insn [ ##add-imm? ] with-available-uses? ;

: fuse-base-offset ( insn -- insn' )
    clone dup base>> vreg>insn
    [ src1>> ] [ src2>> ] bi
    [ >>base ] [ '[ _ + ] change-offset ] bi* ;

! Fuse ##add-imm into ##load-memory and ##store-memory
! just update the offset in the instruction
: fuse-displacement-offset? ( insn -- ? )
    {
        [ scale>> 0 = ]
        [ displacement>> vreg>insn [ ##add-imm? ] with-available-uses? ]
    } 1&& ;

: fuse-displacement-offset ( insn -- insn' )
    clone dup displacement>> vreg>insn
    [ src1>> ] [ src2>> ] bi
    [ >>displacement ] [ '[ _ + ] change-offset ] bi* ;

! Fuse ##add into ##load-memory-imm and ##store-memory-imm
! construct a new ##load-memory or ##store-memory with the
! ##add's operand as the displacement
: fuse-displacement? ( insn -- ? )
    {
        [ offset>> 0 = complex-addressing? or ]
        [ base>> vreg>insn [ ##add? ] with-available-uses? ]
    } 1&& ;

GENERIC: alien-insn-value ( insn -- value )

M: ##load-memory-imm alien-insn-value dst>> ;
M: ##store-memory-imm alien-insn-value src>> ;

GENERIC: new-alien-insn ( value base displacement scale offset rep c-type insn -- insn )

M: ##load-memory-imm new-alien-insn drop ##load-memory new-insn ;
M: ##store-memory-imm new-alien-insn drop ##store-memory new-insn ;

: fuse-displacement ( insn -- insn' )
    {
        [ alien-insn-value ]
        [ base>> vreg>insn [ src1>> ] [ src2>> ] bi ]
        [ drop 0 ]
        [ offset>> ]
        [ rep>> ]
        [ c-type>> ]
        [ ]
    } cleave new-alien-insn ;

! Fuse ##shl-imm into ##load-memory or ##store-memory
: scale-insn? ( insn -- ? )
    { [ ##shl-imm? ] [ src2>> { 1 2 3 } member? ] } 1&& ;

: fuse-scale? ( insn -- ? )
    {
        [ scale>> 0 = ]
        [ displacement>> vreg>insn [ scale-insn? ] with-available-uses? ]
    } 1&& ;

: fuse-scale ( insn -- insn' )
    clone dup displacement>> vreg>insn
    [ src1>> ] [ src2>> ] bi
    [ >>displacement ] [ >>scale ] bi* ;

: rewrite-memory-op ( insn -- insn/f )
    complex-addressing? [
        {
            { [ dup fuse-base-offset? ] [ fuse-base-offset ] }
            { [ dup fuse-displacement-offset? ] [ fuse-displacement-offset ] }
            { [ dup fuse-scale? ] [ fuse-scale ] }
            [ drop f ]
        } cond
    ] [ drop f ] if ;

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
