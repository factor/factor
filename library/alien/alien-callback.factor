! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: compiler-backend compiler-frontend errors generic
hashtables inference inspector kernel lists namespaces sequences
strings words ;

TUPLE: alien-callback return parameters word xt ;
C: alien-callback make-node ;

TUPLE: alien-callback-error ;

M: alien-callback-error summary ( error -- )
    drop "Words calling ``alien-callback'' cannot run in the interpreter. Compile the caller word and try again." ;

: alien-callback ( ... return parameters word -- ... )
    #! Call a C library function.
    #! 'return' is a type spec, and 'parameters' is a list of
    #! type specs. 'library' is an entry in the "libraries"
    #! namespace.
    <alien-callback-error> throw ;

: check-callback ( node -- )
    dup alien-callback-word unit infer dup first
    pick alien-callback-parameters length = >r
    second swap alien-callback-return "void" = 0 1 ? = r> and [
        "Callback word stack effect does not match callback signature" throw
    ] unless ;

: callback-bottom ( node -- )
    alien-callback-xt [ word-xt <alien> ] curry infer-quot ;

\ alien-callback [ [ string object word ] [ alien ] ]
"infer-effect" set-word-prop

\ alien-callback [
    empty-node <alien-callback>
    pop-literal nip over set-alien-callback-word
    pop-literal nip over set-alien-callback-parameters
    pop-literal nip over set-alien-callback-return
    gensym over set-alien-callback-xt
    dup check-callback
    dup node,
    callback-bottom
] "infer" set-word-prop

: linearize-callback ( node -- )
    dup alien-callback-xt [
        alien-callback-word %jump ,
    ] make-linear ;

M: alien-callback linearize* ( node -- )
    dup linearize-callback linearize-next ;
