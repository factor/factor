! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces layouts sequences kernel math accessors
compiler.tree.propagation.info compiler.cfg.stacks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.builder.blocks
compiler.cfg.utilities ;
FROM: vm => context-field-offset ;
IN: compiler.cfg.intrinsics.misc

: emit-tag ( -- )
    ds-pop tag-mask get ^^and-imm ^^tag-fixnum ds-push ;

: emit-special-object ( node -- )
    dup node-input-infos first literal>> [
        "special-objects" ^^vm-field-ptr
        ds-drop swap 0 ^^slot-imm
        ds-push
    ] [ emit-primitive ] ?if ;

: context-object-offset ( -- n )
    "context-objects" context-field-offset cell /i ;

: emit-context-object ( node -- )
    dup node-input-infos first literal>> [
        "ctx" ^^vm-field
        ds-drop swap context-object-offset + 0 ^^slot-imm ds-push
    ] [ emit-primitive ] ?if ;

: emit-identity-hashcode ( -- )
    ds-pop tag-mask get bitnot ^^load-immediate ^^and 0 0 ^^slot-imm
    hashcode-shift ^^shr-imm
    ^^tag-fixnum
    ds-push ;
