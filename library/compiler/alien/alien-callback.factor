! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler errors generic hashtables inference
kernel namespaces sequences strings words parser prettyprint ;

! Callbacks are registered in a global hashtable. If you clear
! this hashtable, they will all be blown away by code GC, beware
SYMBOL: callbacks

H{ } clone callbacks set-global

: register-callback ( word -- ) dup callbacks get set-hash ;

TUPLE: alien-callback return parameters quot xt ;
C: alien-callback make-node ;

TUPLE: alien-callback-error ;

: alien-callback ( return parameters quot -- alien )
    <alien-callback-error> throw ;

M: alien-callback-error summary
    drop "Words calling ``alien-callback'' cannot run in the interpreter. Compile the caller word and try again." ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry infer-quot ;

\ alien-callback [ string object quotation ] [ alien ] <effect>
"inferred-effect" set-word-prop

\ alien-callback [
    empty-node <alien-callback> dup node,
    pop-literal nip over set-alien-callback-quot
    pop-literal nip over set-alien-callback-parameters
    pop-literal nip over set-alien-callback-return
    gensym dup register-callback over set-alien-callback-xt
    callback-bottom
] "infer" set-word-prop

: box-parameters ( parameters -- )
    [ c-type c-type-box ] each-parameter ;

: registers>objects ( parameters -- )
    dup \ %freg>stack move-parameters
    "nest_stacks" f %alien-invoke box-parameters ;

: unbox-return ( node -- )
    alien-callback-return [
        "unnest_stacks" f %alien-invoke
    ] [
        c-type dup c-type-reg-class
        swap c-type-unboxer
        %callback-value
    ] if-void ;

: alien-callback-quot* ( node -- quot )
    [
        \ init-error-handler ,
        dup alien-callback-quot %
        alien-callback-return
        [ ] [ c-type c-type-prep % ] if-void
    ] [ ] make ;

: generate-callback ( node -- )
    [ alien-callback-xt ] keep [
        dup alien-callback-parameters registers>objects
        dup alien-callback-quot* %alien-callback
        unbox-return
        %return
    ] generate-1 ;

M: alien-callback generate-node
    end-basic-block generate-callback iterate-next ;

M: alien-callback stack-reserve*
    alien-callback-parameters stack-space ;
