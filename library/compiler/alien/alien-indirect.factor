! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler errors generic hashtables inference
kernel namespaces sequences strings words parser prettyprint ;

TUPLE: alien-indirect return parameters abi ;
C: alien-indirect make-node ;

TUPLE: alien-indirect-error ;

: alien-indirect ( funcptr args... return parameters abi -- )
    <alien-indirect-error> throw ;

M: alien-indirect-error summary
    drop "Words calling ``alien-indirect'' cannot run in the interpreter. Compile the caller word and try again." ;

\ alien-indirect [ string object string ] [ ] <effect>
"infer-effect" set-word-prop

\ alien-indirect [
    empty-node <alien-indirect>
    pop-literal nip over set-alien-indirect-abi
    pop-literal nip over set-alien-indirect-parameters
    pop-literal nip over set-alien-indirect-return
    dup alien-indirect-parameters
    make-prep-quot 1 make-dip infer-quot
    node,
] "infer" set-word-prop

: generate-indirect-cleanup ( node -- )
    dup alien-indirect-abi "stdcall" = [
        drop
    ] [
        alien-indirect-parameters stack-space %cleanup
    ] if ;

M: alien-indirect generate-node
    end-basic-block
    %prepare-alien-indirect
    dup alien-indirect-parameters objects>registers
    %alien-indirect
    dup generate-indirect-cleanup
    alien-indirect-return box-return
    iterate-next ;

M: alien-indirect stack-reserve*
    alien-indirect-parameters stack-space ;
