! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: generator errors generic assocs inference
kernel namespaces sequences strings words parser prettyprint
kernel-internals threads libc math quotations inspector ;

! Callbacks are registered in a global hashtable. If you clear
! this hashtable, they will all be blown away by code GC, beware
SYMBOL: callbacks

H{ } clone callbacks set-global

: register-callback ( word -- ) dup callbacks get set-at ;

TUPLE: alien-callback return parameters abi quot xt ;

C: alien-callback make-node ;

M: alien-callback alien-node-parameters alien-callback-parameters ;
M: alien-callback alien-node-return alien-callback-return ;
M: alien-callback alien-node-abi alien-callback-abi ;

TUPLE: alien-callback-error ;

: alien-callback ( return parameters abi quot -- alien )
    <alien-callback-error> throw ;

M: alien-callback-error summary
    drop "Words calling ``alien-callback'' cannot run in the interpreter. Compile the caller word and try again." ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry infer-quot ;

\ alien-callback [
    4 ensure-values
    empty-node <alien-callback> dup node,
    pop-literal nip over set-alien-callback-quot
    pop-literal nip over set-alien-callback-abi
    pop-literal nip over set-alien-callback-parameters
    pop-literal nip over set-alien-callback-return
    gensym dup register-callback over set-alien-callback-xt
    callback-bottom
] "infer" set-word-prop

: box-parameters ( node -- )
    alien-node-parameters* [ box-parameter ] each-parameter ;

: registers>objects ( node -- )
    [
        dup \ %save-param-reg move-parameters
        "nest_stacks" f %alien-invoke
        box-parameters
    ] with-param-regs ;

TUPLE: callback-context ;

: current-callback 0 getenv ;

: wait-to-return ( token -- )
    dup current-callback eq? [
        drop
    ] [
        yield wait-to-return
    ] if ;

: do-callback ( quot token -- )
    init-error-handler
    dup 0 setenv
    slip
    wait-to-return ; inline

: prepare-callback-return ( ctype -- quot )
    alien-node-return {
        { [ dup "void" = ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size [ memcpy ] curry ] }
        { [ t ] [ c-type c-type-prep ] }
    } cond ;

: wrap-callback-quot ( node -- quot )
    [
        dup alien-callback-quot
        swap prepare-callback-return append ,
        [ <callback-context> do-callback ] %
    ] [ ] make ;

: %unnest-stacks ( -- ) "unnest_stacks" f %alien-invoke ;

: callback-unwind ( node -- n )
    {
        { [ dup alien-node-abi "stdcall" = ] [ alien-stack-frame ] }
        { [ dup alien-node-return large-struct? ] [ drop 4 ] }
        { [ t ] [ drop 0 ] }
    } cond ;

: %callback-return ( node -- )
    #! All the extra book-keeping for %unwind is only for x86.
    #! On other platforms its an alias for %return.
    dup alien-node-return*
    [ %unnest-stacks ] [ %callback-value ] if-void
    callback-unwind %unwind ;

: generate-callback ( node -- )
    dup alien-callback-xt dup rot [
        dup alien-stack-frame [
            init-templates
            dup registers>objects
            dup wrap-callback-quot %alien-callback
            %callback-return
        ] with-stack-frame
    ] generate-1 ;

M: alien-callback generate-node
    end-basic-block generate-callback iterate-next ;
