! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.algebra layouts kernel math namespaces
sequences cpu.architecture
compiler.tree.propagation.info
compiler.cfg.stacks
compiler.cfg.hats
compiler.cfg.comparisons
compiler.cfg.instructions
compiler.cfg.builder.blocks
compiler.cfg.utilities ;
FROM: vm => context-field-offset vm-field-offset ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.cfg.intrinsics.misc

: emit-tag ( -- )
    [ ^^tagged>integer tag-mask get ^^and-imm ] unary-op ;

: emit-eq ( node -- )
    node-input-infos first2 [ class>> fixnum class<= ] both?
    [ [ cc= ^^compare-integer ] binary-op ] [ [ cc= ^^compare ] binary-op ] if ;

: special-object-offset ( n -- offset )
    cells "special-objects" vm-field-offset + ;

: emit-special-object ( node -- )
    dup node-input-infos first literal>> [
        ds-drop
        special-object-offset ^^vm-field
        ds-push
    ] [ emit-primitive ] ?if ;

: emit-set-special-object ( node -- )
    dup node-input-infos second literal>> [
        ds-drop
        [ ds-pop ] dip special-object-offset ##set-vm-field
    ] [ emit-primitive ] ?if ;

: context-object-offset ( n -- n )
    cells "context-objects" context-field-offset + ;

: emit-context-object ( node -- )
    dup node-input-infos first literal>> [
        "ctx" vm-field-offset ^^vm-field
        ds-drop swap context-object-offset cell /i 0 ^^slot-imm ds-push
    ] [ emit-primitive ] ?if ;

: emit-identity-hashcode ( -- )
    [
        ^^tagged>integer
        tag-mask get bitnot ^^load-integer ^^and
        0 int-rep f ^^load-memory-imm
        hashcode-shift ^^shr-imm
    ] unary-op ;

: emit-local-allot ( node -- )
    dup node-input-infos first literal>> dup integer?
    [ nip ds-drop f ^^local-allot ^^box-alien ds-push ]
    [ drop emit-primitive ]
    if ;
