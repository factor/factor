! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: layouts namespaces kernel accessors sequences math
classes.algebra classes.builtin locals combinators
cpu.architecture compiler.tree.propagation.info
compiler.cfg.stacks compiler.cfg.hats compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.utilities
compiler.cfg.builder.blocks compiler.constants ;
IN: compiler.cfg.intrinsics.slots

: class-tag ( class -- tag/f )
    builtins get [ class<= ] with find drop ;

: value-tag ( info -- n ) class>> class-tag ;

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

: immediate-slot-offset? ( value-info -- ? )
    literal>> {
        { [ dup fixnum? ] [ tag-fixnum immediate-arithmetic? ] }
        [ drop f ]
    } cond ;

: emit-slot ( node -- )
    dup node-input-infos
    dup first value-tag [
        nip
        dup second immediate-slot-offset?
        [ (emit-slot-imm) ] [ (emit-slot) ] if
        ds-push
    ] [ drop emit-primitive ] if ;

: emit-write-barrier? ( infos -- ? )
    first class>> immediate class<= not ;

:: (emit-set-slot) ( infos -- )
    3inputs :> ( src obj slot )

    slot infos second value-tag ^^tag-offset>slot :> slot

    src obj slot ##set-slot

    infos emit-write-barrier?
    [ obj slot next-vreg next-vreg ##write-barrier ] when ;

:: (emit-set-slot-imm) ( infos -- )
    ds-drop

    2inputs :> ( src obj )

    infos third literal>> :> slot
    infos second value-tag :> tag

    src obj slot tag ##set-slot-imm

    infos emit-write-barrier?
    [ obj slot tag slot-offset next-vreg next-vreg ##write-barrier-imm ] when ;

: emit-set-slot ( node -- )
    dup node-input-infos
    dup second value-tag [
        nip
        dup third immediate-slot-offset?
        [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if
    ] [ drop emit-primitive ] if ;

: emit-string-nth ( -- )
    2inputs swap ^^untag-fixnum ^^string-nth ^^tag-fixnum ds-push ;

: emit-set-string-nth-fast ( -- )
    3inputs [ ^^untag-fixnum ] [ ^^untag-fixnum ] [ ] tri*
    swap next-vreg ##set-string-nth-fast ;
