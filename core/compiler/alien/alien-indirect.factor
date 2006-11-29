! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler errors generic hashtables inference
kernel namespaces sequences strings words parser prettyprint ;

TUPLE: alien-indirect return parameters abi ;
C: alien-indirect make-node ;

M: alien-indirect alien-invoke-parameters alien-indirect-parameters ;
M: alien-indirect alien-invoke-return alien-indirect-return ;
M: alien-indirect alien-invoke-abi alien-indirect-abi ;

TUPLE: alien-indirect-error ;

: alien-indirect ( funcptr args... return parameters abi -- )
    <alien-indirect-error> throw ;

M: alien-indirect-error summary
    drop "Words calling ``alien-indirect'' cannot run in the interpreter. Compile the caller word and try again." ;

\ alien-indirect [ string object string ] [ ] <effect>
"inferred-effect" set-word-prop

: alien-indirect-stack ( node -- )
    1 over consume-values
    alien-invoke-stack ;

\ alien-indirect [
    empty-node <alien-indirect>
    pop-literal nip over set-alien-indirect-abi
    pop-literal nip over set-alien-indirect-parameters
    pop-literal nip over set-alien-indirect-return
    dup alien-indirect-parameters
    make-prep-quot 1 make-dip infer-quot
    dup node,
    alien-indirect-stack
] "infer" set-word-prop

M: alien-indirect generate-node
    end-basic-block
    %prepare-alien-indirect
    dup alien-indirect-parameters objects>registers
    %alien-indirect
    dup generate-invoke-cleanup
    alien-indirect-return box-return
    iterate-next ;

M: alien-indirect stack-reserve*
    alien-indirect-parameters stack-space ;
