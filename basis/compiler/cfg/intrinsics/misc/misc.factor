! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces layouts sequences kernel math accessors
compiler.tree.propagation.info compiler.cfg.stacks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.utilities ;
IN: compiler.cfg.intrinsics.misc

: emit-tag ( -- )
    ds-pop tag-mask get ^^and-imm ^^tag-fixnum ds-push ;

: emit-getenv ( node -- )
    "userenv" ^^vm-field-ptr
    swap node-input-infos first literal>>
    [ ds-drop 0 ^^slot-imm ] [ ds-pop ^^offset>slot ^^slot ] if*
    ds-push ;

: emit-identity-hashcode ( -- )
    ds-pop tag-mask get bitnot ^^load-immediate ^^and 0 0 ^^slot-imm
    hashcode-shift ^^shr-imm
    ^^tag-fixnum
    ds-push ;
