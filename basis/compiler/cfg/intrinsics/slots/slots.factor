! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra classes.builtin
combinators.short-circuit compiler.cfg.builder.blocks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks
compiler.tree.propagation.info cpu.architecture kernel layouts
math namespaces sequences ;
IN: compiler.cfg.intrinsics.slots

: class-tag ( class -- tag/f )
    builtins get [ class<= ] with find drop ;

: value-tag ( info -- n/f )
    class>> class-tag ;

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

: immediate-slot-offset? ( object -- ? )
    { [ fixnum? ] [ cell * immediate-arithmetic? ] } 1&& ;

: emit-slot ( block node -- block' )
    dup node-input-infos
    dup first value-tag [
        nip
        dup second literal>> immediate-slot-offset?
        [ (emit-slot-imm) ] [ (emit-slot) ] if
        ds-push
    ] [ drop emit-primitive ] if ;

:: (emit-set-slot-imm) ( write-barrier? tag slot -- )
    ds-drop

    2inputs :> ( src obj )

    src obj slot tag ##set-slot-imm,

    write-barrier?
    [ obj slot tag next-vreg next-vreg ##write-barrier-imm, ] when ;

:: (emit-set-slot) ( write-barrier? tag -- )
    3inputs :> ( src obj slot )

    slot tag slot-indexing :> ( slot scale tag )

    src obj slot scale tag ##set-slot,

    write-barrier?
    [ obj slot scale tag next-vreg next-vreg ##write-barrier, ] when ;

: node>set-slot-data ( #call -- write-barrier? tag literal )
    node-input-infos first3
    [ class>> immediate class<= not ] [ value-tag ] [ literal>> ] tri* ;

: emit-intrinsic-set-slot ( write-barrier? tag index-info -- )
    dup immediate-slot-offset? [
        (emit-set-slot-imm)
    ] [ drop (emit-set-slot) ] if ;

: emit-set-slot ( block #call -- block' )
    dup node>set-slot-data over [
        emit-intrinsic-set-slot drop
    ] [ 3drop emit-primitive ] if ;
