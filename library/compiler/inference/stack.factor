IN: inference
USING: arrays generic kernel math namespaces
sequences words parser ;

: infer-shuffle-inputs ( shuffle node -- )
    >r dup shuffle-in-d length swap shuffle-in-r length r>
    node-inputs ;

: shuffle-stacks ( shuffle -- )
    #! Shuffle simulated stacks.
    meta-d get meta-r get rot shuffle meta-r set meta-d set ;

: infer-shuffle-outputs ( shuffle node -- )
    >r dup shuffle-out-d length swap shuffle-out-r length r>
    node-outputs ;

: infer-shuffle ( shuffle -- )
    #shuffle dup node,
    2dup infer-shuffle-inputs
    over shuffle-stacks
    infer-shuffle-outputs ;

: shuffle>effect ( shuffle -- effect )
    dup shuffle-in-d swap shuffle-out-d <effect> ;

: define-shuffle ( word shuffle -- )
    [ "shuffle" set-word-prop ] 2keep
    [ shuffle>effect "infer-effect" set-word-prop ] 2keep
    [ , \ infer-shuffle , ] [ ] make "infer" set-word-prop ;

{
    { drop  T{ shuffle f 1 0 {             } {   } } }
    { 2drop T{ shuffle f 2 0 {             } {   } } }
    { 3drop T{ shuffle f 3 0 {             } {   } } }
    { dup   T{ shuffle f 1 0 { 0 0         } {   } } }
    { 2dup  T{ shuffle f 2 0 { 0 1 0 1     } {   } } }
    { 3dup  T{ shuffle f 3 0 { 0 1 2 0 1 2 } {   } } }
    { rot   T{ shuffle f 3 0 { 1 2 0       } {   } } }
    { -rot  T{ shuffle f 3 0 { 2 0 1       } {   } } }
    { dupd  T{ shuffle f 2 0 { 0 0 1       } {   } } }
    { swapd T{ shuffle f 3 0 { 1 0 2       } {   } } }
    { nip   T{ shuffle f 2 0 { 1           } {   } } }
    { 2nip  T{ shuffle f 3 0 { 2           } {   } } }
    { tuck  T{ shuffle f 2 0 { 1 0 1       } {   } } }
    { over  T{ shuffle f 2 0 { 0 1 0       } {   } } }
    { pick  T{ shuffle f 3 0 { 0 1 2 0     } {   } } }
    { swap  T{ shuffle f 2 0 { 1 0         } {   } } }
    { >r    T{ shuffle f 1 0 {             } { 0 } } }
    { r>    T{ shuffle f 0 1 { 0           } {   } } }
} [ first2 define-shuffle ] each
