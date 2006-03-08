! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler-backend compiler-frontend errors generic
hashtables inference inspector kernel lists namespaces sequences
strings words ;

TUPLE: alien-callback return parameters quot xt ;
C: alien-callback make-node ;

TUPLE: alien-callback-error ;

M: alien-callback-error summary ( error -- )
    drop "Words calling ``alien-callback'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-callback ( ... return parameters quot -- ... )
    <alien-callback-error> throw ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry infer-quot ;

\ alien-callback [ [ string object general-list ] [ alien ] ]
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
    [ box-parameter ] map-parameters % ;

: registers>objects ( parameters -- )
    dup \ %freg>stack move-parameters %
    "nest_stacks" f %alien-invoke , box-parameters ;

: unbox-return ( node -- )
    alien-callback-return [
        "unnest_stacks" f %alien-invoke ,
    ] [
        c-type [
            "reg-class" get
            "unboxer-function" get
            %callback-value ,
        ] bind
    ] if-void ;

: linearize-callback ( node -- )
    dup alien-callback-xt [
        dup stack-reserve* %prologue ,
        dup alien-callback-parameters registers>objects
        dup alien-callback-quot \ init-error-handler swons
        %alien-callback ,
        unbox-return
        %return ,
    ] make-linear ;

M: alien-callback linearize* ( node -- )
    compile-gc linearize-callback iterate-next ;

M: alien-callback stack-reserve*
    alien-callback-parameters stack-space ;
