! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: interpreter kernel namespaces words ;

\ >r [
    f \ >r dataflow, [ 1 0 node-inputs ] extend
    pop-d push-r
    [ 0 1 node-outputs ] bind
] "infer" set-word-prop

\ r> [
    f \ r> dataflow, [ 0 1 node-inputs ] extend
    pop-r push-d
    [ 1 0 node-outputs ] bind
] "infer" set-word-prop

: infer-shuffle ( word -- )
    f over dup
    "infer-effect" word-prop
    [ host-word ] with-dataflow ;

\ drop [ \ drop infer-shuffle ] "infer" set-word-prop
\ dup  [ \ dup  infer-shuffle ] "infer" set-word-prop
\ swap [ \ swap infer-shuffle ] "infer" set-word-prop
\ over [ \ over infer-shuffle ] "infer" set-word-prop
\ pick [ \ pick infer-shuffle ] "infer" set-word-prop
