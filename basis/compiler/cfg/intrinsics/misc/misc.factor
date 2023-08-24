! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra classes.struct
compiler.cfg.builder.blocks compiler.cfg.comparisons
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.stacks
compiler.constants compiler.tree.propagation.info
cpu.architecture kernel layouts math namespaces sequences vm ;
IN: compiler.cfg.intrinsics.misc

: emit-tag ( -- )
    [ ^^tagged>integer tag-mask get ^^and-imm ] unary-op ;

: emit-eq ( node -- )
    node-input-infos first2 [ class>> fixnum class<= ] both?
    [ [ cc= ^^compare-integer ] binary-op ] [ [ cc= ^^compare ] binary-op ] if ;

: emit-special-object ( block node -- block' )
    [ node-input-infos first literal>> ]
    [
        ds-drop
        vm-special-object-offset ^^vm-field
        ds-push
    ] [ emit-primitive ] ?if ;

: emit-set-special-object ( block node -- block' )
    [ node-input-infos second literal>> ]
    [
        ds-drop
        [ ds-pop ] dip vm-special-object-offset ##set-vm-field,
    ] [ emit-primitive ] ?if ;

: context-object-offset ( n -- n )
    cells "context-objects" context offset-of + ;

: emit-context-object ( block node -- block' )
    [ node-input-infos first literal>> ] [
        "ctx" vm offset-of ^^vm-field
        ds-drop swap context-object-offset cell /i 0 ^^slot-imm ds-push
    ] [ emit-primitive ] ?if ;

: emit-identity-hashcode ( -- )
    [
        ^^tagged>integer
        tag-mask get bitnot ^^load-integer ^^and
        0 int-rep f ^^load-memory-imm
        hashcode-shift ^^shr-imm
    ] unary-op ;

: emit-local-allot ( block node -- block' )
    dup node-input-infos first2 [ literal>> ] bi@ 2dup [ integer? ] both?
    [ ds-drop ds-drop f ^^local-allot ^^box-alien ds-push drop ]
    [ 2drop emit-primitive ] if ;

: emit-cleanup-allot ( block node -- block' )
    drop [ drop ##no-tco, ] emit-trivial-block ;
