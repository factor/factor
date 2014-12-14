! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra classes.builtin
combinators.short-circuit compiler.cfg.builder.blocks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks
compiler.tree.propagation.info cpu.architecture kernel layouts
locals math namespaces sequences ;
IN: compiler.cfg.intrinsics.slots

: class-tag ( class -- tag/f )
    builtins get [ class<= ] with find drop ;

: value-tag ( info -- n ) class>> class-tag ;

: slot-indexing ( slot tag -- slot scale tag )
    complex-addressing?
    [ [ cell log2 ] dip ] [ [ ^^offset>slot ] dip ^^sub-imm 0 0 ] if ;

: (emit-slot) ( infos -- dst )
    [ 2inputs ] [ first value-tag ] bi*
    slot-indexing ^^slot ;

: (emit-slot-imm) ( infos -- dst )
    ds-drop
    [ ds-pop ]
    [ [ second literal>> ] [ first value-tag ] bi ] bi*
    ^^slot-imm ;

: immediate-slot-offset? ( value-info -- ? )
    literal>> {
        [ fixnum? ]
        [ cell * immediate-arithmetic? ]
    } 1&& ;

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

    infos second value-tag :> tag

    slot tag slot-indexing :> ( slot scale tag )
    src obj slot scale tag ##set-slot,

    infos emit-write-barrier?
    [ obj slot scale tag next-vreg next-vreg ##write-barrier, ] when ;

:: (emit-set-slot-imm) ( infos -- )
    ds-drop

    2inputs :> ( src obj )

    infos third literal>> :> slot
    infos second value-tag :> tag

    src obj slot tag ##set-slot-imm,

    infos emit-write-barrier?
    [ obj slot tag next-vreg next-vreg ##write-barrier-imm, ] when ;

: emit-set-slot ( node -- )
    dup node-input-infos
    dup second value-tag [
        nip
        dup third immediate-slot-offset?
        [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if
    ] [ drop emit-primitive ] if ;
