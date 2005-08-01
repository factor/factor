! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: interpreter kernel namespaces sequences words ;

\ >r [
    \ >r #call
    1 0 pick node-inputs
    pop-d push-r
    0 1 pick node-outputs
    node,
] "infer" set-word-prop

\ r> [
    \ r> #call
    0 1 pick node-inputs
    pop-r push-d
    1 0 pick node-outputs
    node,
] "infer" set-word-prop

: with-datastack ( stack word -- stack )
    datastack >r >r set-datastack r> execute
    datastack r> [ push ] keep set-datastack 2nip ;

: apply-datastack ( word -- )
    meta-d [ swap with-datastack ] change ;

: infer-shuffle ( word -- )
    dup #call [
        over "infer-effect" word-prop
        [ apply-datastack ] hairy-node
    ] keep node, ;

\ drop [ 1 #drop node, pop-d drop ] "infer" set-word-prop
\ dup  [ \ dup  infer-shuffle ] "infer" set-word-prop
\ swap [ \ swap infer-shuffle ] "infer" set-word-prop
\ over [ \ over infer-shuffle ] "infer" set-word-prop
\ pick [ \ pick infer-shuffle ] "infer" set-word-prop
