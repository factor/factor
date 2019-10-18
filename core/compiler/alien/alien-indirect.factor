! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: generator errors generic hashtables inference
kernel namespaces sequences strings words parser prettyprint
kernel-internals math ;

TUPLE: alien-indirect return parameters abi ;
C: alien-indirect make-node ;

M: alien-indirect alien-node-parameters alien-indirect-parameters ;
M: alien-indirect alien-node-return alien-indirect-return ;
M: alien-indirect alien-node-abi alien-indirect-abi ;

TUPLE: alien-indirect-error ;

: alien-indirect ( ... funcptr return parameters abi -- )
    <alien-indirect-error> throw ;

M: alien-indirect-error summary
    drop "Words calling ``alien-indirect'' cannot run in the interpreter. Compile the caller word and try again." ;

\ alien-indirect [
    ! Three literals and function pointer
    4 ensure-values
    empty-node <alien-indirect>
    ! Compile-time parameters
    pop-literal nip over set-alien-indirect-abi
    pop-literal nip over set-alien-indirect-parameters
    pop-literal nip over set-alien-indirect-return
    ! Quotation which coerces parameters to required types
    dup make-prep-quot 1 make-dip infer-quot
    ! Add node to IR
    dup node,
    ! Magic #: consume the function pointer, too
    1 alien-invoke-stack
] "infer" set-word-prop

M: alien-indirect generate-node
    end-basic-block
    ! Save alien at top of stack to temporary storage
    %prepare-alien-indirect
    dup objects>registers
    ! Call alien in temporary storage
    %alien-indirect
    dup %cleanup
    box-return*
    iterate-next ;

M: alien-indirect stack-frame-size* alien-invoke-frame ;
