! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler errors generic hashtables inference inspector
kernel namespaces sequences strings words ;

TUPLE: alien-callback return parameters quot xt ;
C: alien-callback make-node ;

TUPLE: alien-callback-error ;

: alien-callback ( return parameters quot -- address )
    <alien-callback-error> throw ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry infer-quot ;

\ alien-callback [ [ string object quotation ] [ alien ] ]
"infer-effect" set-word-prop

\ alien-callback [
    empty-node <alien-callback>
    pop-literal nip over set-alien-callback-quot
    pop-literal nip over set-alien-callback-parameters
    pop-literal nip over set-alien-callback-return
    gensym over set-alien-callback-xt
    dup node,
    callback-bottom
] "infer" set-word-prop

: box-parameters ( parameters -- )
    [ box-parameter ] each-parameter ;

: registers>objects ( parameters -- )
    dup \ %freg>stack move-parameters
    "nest_stacks" f %alien-invoke box-parameters ;

: unbox-return ( node -- )
    alien-callback-return [
        "unnest_stacks" f %alien-invoke
    ] [
        c-type [
            "reg-class" get
            "unboxer-function" get
            %callback-value
        ] bind
    ] if-void ;

: generate-callback ( node -- )
    [ alien-callback-xt ] keep [
        dup alien-callback-parameters registers>objects
        dup alien-callback-quot \ init-error-handler add*
        %alien-callback
        unbox-return
        %return
    ] generate-1 ;

M: alien-callback generate-node ( node -- )
    end-basic-block compile-gc generate-callback iterate-next ;

M: alien-callback stack-reserve*
    alien-callback-parameters stack-space ;
