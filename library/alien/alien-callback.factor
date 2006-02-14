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
    [ box-parameter , ] reverse-each-parameter ;

: registers>objects ( parameters -- )
    #! The corresponding unnest_stacks() call is made by the
    #! run_nullary_callback() and run_unary_callback() runtime
    #! functions.
    dup stack-space %parameters ,
    dup \ %freg>stack move-parameters
    "nest_stacks" f %alien-invoke ,
    box-parameters ;

: linearize-callback ( node -- )
    dup alien-callback-xt [
        dup alien-callback-parameters registers>objects
        alien-callback-quot %nullary-callback ,
        %return ,
    ] make-linear ;

M: alien-callback linearize* ( node -- )
    dup linearize-callback linearize-next ;
