! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: layouts namespaces kernel accessors sequences
classes.algebra compiler.tree.propagation.info
compiler.cfg.stacks compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.intrinsics.utilities ;
IN: compiler.cfg.intrinsics.slots

: emit-tag ( -- )
    ds-pop tag-mask get ^^and-imm ^^tag-fixnum ds-push ;

: value-tag ( info -- n ) class>> class-tag ; inline

: (emit-slot) ( infos -- dst )
    [ 2inputs ] [ first value-tag ] bi*
    ^^slot ;

: (emit-slot-imm) ( infos -- dst )
    ds-drop
    [ ds-pop ^^offset>slot ]
    [ [ second literal>> ] [ first value-tag ] bi ] bi*
    ^^slot-imm ;

: emit-slot ( node -- )
    dup node-input-infos
    dup first value-tag [
        nip
        dup second value-info-small-tagged?
        [ (emit-slot-imm) ] [ (emit-slot) ] if
        ds-push
    ] [ drop emit-primitive ] if ;

: (emit-set-slot) ( infos -- obj-reg )
    [ 3inputs [ tuck ] dip ^^offset>slot ]
    [ second value-tag ]
    bi* ^^set-slot ;

: (emit-set-slot-imm) ( infos -- obj-reg )
    ds-drop
    [ 2inputs tuck ]
    [ [ third literal>> ] [ second value-tag ] bi ] bi*
    ##set-slot-imm ;

: emit-set-slot ( node -- )
    dup node-input-infos
    dup second value-tag [
        nip
        ds-drop
        [
            dup third value-info-small-tagged?
            [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if
        ] [ first class>> immediate class<= ] bi
        [ drop ] [ i i ##write-barrier ] if
    ] [ drop emit-primitive ] if ;
