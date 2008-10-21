! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: layouts namespaces kernel accessors sequences
classes.algebra compiler.tree.propagation.info
compiler.cfg.stacks compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.intrinsics.utilities ;
IN: compiler.cfg.intrinsics.slots

: emit-tag ( -- )
    phantom-pop tag-mask get ^^and-imm ^^tag-fixnum phantom-push ;

: value-tag ( info -- n ) class>> class-tag ; inline

: (emit-slot) ( infos -- dst )
    [ 2phantom-pop ] [ first value-tag ] bi*
    ^^slot ;

: (emit-slot-imm) ( infos -- dst )
    1 phantom-drop
    [ phantom-pop ^^offset>slot ]
    [ [ second literal>> ] [ first value-tag ] bi ] bi*
    ^^slot-imm ;

: emit-slot ( node -- )
    dup node-input-infos
    dup first value-tag [
        nip
        dup second value-info-small-tagged?
        [ (emit-slot-imm) ] [ (emit-slot) ] if
        phantom-push
    ] [ drop emit-primitive ] if ;

: (emit-set-slot) ( infos -- obj-reg )
    [ 3phantom-pop [ tuck ] dip ^^offset>slot ]
    [ second value-tag ]
    bi* ^^set-slot ;

: (emit-set-slot-imm) ( infos -- obj-reg )
    1 phantom-drop
    [ 2phantom-pop tuck ]
    [ [ third literal>> ] [ second value-tag ] bi ] bi*
    ##set-slot-imm ;

: emit-set-slot ( node -- )
    dup node-input-infos
    dup second value-tag [
        nip
        1 phantom-drop
        [
            dup third value-info-small-tagged?
            [ (emit-set-slot-imm) ] [ (emit-set-slot) ] if
        ] [ first class>> immediate class<= ] bi
        [ drop ] [ ^^write-barrier ] if
    ] [ drop emit-primitive ] if ;
