! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces layouts sequences kernel math accessors
compiler.tree.propagation.info compiler.cfg.stacks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.builder.blocks
compiler.cfg.utilities ;
FROM: vm => context-field-offset vm-field-offset ;
IN: compiler.cfg.intrinsics.misc

: emit-tag ( -- )
    ds-pop tag-mask get ^^and-imm ^^tag-fixnum ds-push ;

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
    ds-pop tag-mask get bitnot ^^load-immediate ^^and 0 0 ^^slot-imm
    hashcode-shift ^^shr-imm
    ^^tag-fixnum
    ds-push ;
