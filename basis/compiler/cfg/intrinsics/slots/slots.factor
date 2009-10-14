! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: layouts namespaces kernel accessors sequences classes.algebra
fry compiler.tree.propagation.info compiler.cfg.stacks compiler.cfg.hats
compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.utilities compiler.cfg.builder.blocks ;
IN: compiler.cfg.intrinsics.slots

: value-tag ( info -- n ) class>> class-tag ; inline

: ^^tag-offset>slot ( slot tag -- vreg' )
    [ ^^offset>slot ] dip ^^sub-imm ;

: (emit-slot) ( infos -- dst )
    [ 2inputs ] [ first value-tag ] bi*
    ^^tag-offset>slot ^^slot ;

: (emit-slot-imm) ( infos -- dst )
    ds-drop
    [ ds-pop ]
    [ [ second literal>> ] [ first value-tag ] bi ] bi*
    ^^slot-imm ;

: emit-slot ( node -- )
    dup node-input-infos
    dup first value-tag [
        nip
        dup second value-info-small-fixnum?
        [ (emit-slot-imm) ] [ (emit-slot) ] if
        ds-push
    ] [ drop emit-primitive ] if ;

: (emit-set-slot) ( infos -- )
    [ first class>> immediate class<= ]
    [ [ 3inputs ] [ second value-tag ] bi* ^^tag-offset>slot ] bi
    [ ##set-slot ]
    [ '[ _ drop _ _ next-vreg next-vreg ##write-barrier ] unless ] 3bi ;

: (emit-set-slot-imm) ( infos -- )
    ds-drop
    [ first class>> immediate class<= ]
    [ [ 2inputs ] [ [ third literal>> ] [ second value-tag ] bi ] bi* ] bi
    '[ _ ##set-slot-imm ]
    [ '[ _ drop _ _ cells next-vreg next-vreg ##write-barrier-imm ] unless ] 3bi ;

: emit-set-slot ( node -- )
    dup node-input-infos
    dup second value-tag [
        nip
        dup third value-info-small-fixnum?
        [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if
    ] [ drop emit-primitive ] if ;

: emit-string-nth ( -- )
    2inputs swap ^^untag-fixnum ^^string-nth ^^tag-fixnum ds-push ;

: emit-set-string-nth-fast ( -- )
    3inputs [ ^^untag-fixnum ] [ ^^untag-fixnum ] [ ] tri*
    swap next-vreg ##set-string-nth-fast ;
