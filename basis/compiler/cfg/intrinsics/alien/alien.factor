! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences alien math classes.algebra fry
locals combinators combinators.short-circuit cpu.architecture
compiler.tree.propagation.info compiler.cfg.hats
compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.instructions compiler.cfg.utilities
compiler.cfg.builder.blocks ;
IN: compiler.cfg.intrinsics.alien

: emit-<displaced-alien>? ( node -- ? )
    node-input-infos {
        [ first class>> fixnum class<= ]
        [ second class>> c-ptr class<= ]
    } 1&& ;

: emit-<displaced-alien> ( node -- )
    dup emit-<displaced-alien>? [
        '[
            _ node-input-infos second class>>
            ^^box-displaced-alien
        ] binary-op
    ] [ emit-primitive ] if ;

:: inline-accessor ( node quot test -- )
    node node-input-infos :> infos
    infos test call
    [ infos quot call ]
    [ node emit-primitive ] if ; inline

: inline-load-memory? ( infos -- ? )
    [ first class>> c-ptr class<= ]
    [ second class>> fixnum class<= ]
    bi and ;

: prepare-accessor ( base offset info -- base offset )
    class>> swap [ ^^unbox-c-ptr ] dip ^^add 0 ;

: prepare-load-memory ( infos -- base offset )
    [ 2inputs ] dip first prepare-accessor ;

: (emit-load-memory) ( node rep c-type quot -- )
    '[ prepare-load-memory _ _ ^^load-memory-imm @ ds-push ]
    [ inline-load-memory? ]
    inline-accessor ; inline

: emit-load-memory ( node rep c-type -- )
    [ ] (emit-load-memory) ;

: emit-alien-cell ( node -- )
    int-rep f [ ^^box-alien ] (emit-load-memory) ;

: inline-store-memory? ( infos class -- ? )
    '[ first class>> _ class<= ]
    [ second class>> c-ptr class<= ]
    [ third class>> fixnum class<= ]
    tri and and ;

: prepare-store-memory ( infos -- value base offset )
    [ 3inputs ] dip second prepare-accessor ;

:: (emit-store-memory) ( node rep c-type prepare-quot test-quot -- )
    node
    [ prepare-quot call rep c-type ##store-memory-imm ]
    [ test-quot call inline-store-memory? ]
    inline-accessor ; inline

:: emit-store-memory ( node rep c-type -- )
    node rep c-type
    [ prepare-store-memory ]
    [
        rep {
            { int-rep [ fixnum ] }
            { float-rep [ float ] }
            { double-rep [ float ] }
        } case
    ]
    (emit-store-memory) ;

: emit-set-alien-cell ( node -- )
    int-rep f
    [
        [ first class>> ] [ prepare-store-memory ] bi
        [ swap ^^unbox-c-ptr ] 2dip
    ]
    [ pinned-c-ptr ]
    (emit-store-memory) ;
