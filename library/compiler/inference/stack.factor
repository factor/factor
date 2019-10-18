IN: inference
USING: arrays generic kernel math namespaces
sequences words parser words ;

: infer-shuffle-inputs ( shuffle node -- )
    >r effect-in length 0 r> node-inputs ;

: shuffle-stacks ( shuffle -- )
    meta-d [ swap shuffle ] change ;

: infer-shuffle-outputs ( shuffle node -- )
    >r effect-out length 0 r> node-outputs ;

: infer-shuffle ( shuffle -- )
    #shuffle dup node,
    2dup infer-shuffle-inputs
    over shuffle-stacks
    infer-shuffle-outputs ;

: define-shuffle ( word shuffle -- )
    [ "infer-effect" set-word-prop ] 2keep
    [ infer-shuffle ] curry "infer" set-word-prop ;

{
    { drop  T{ effect f 1 {             } } }
    { 2drop T{ effect f 2 {             } } }
    { 3drop T{ effect f 3 {             } } }
    { dup   T{ effect f 1 { 0 0         } } }
    { 2dup  T{ effect f 2 { 0 1 0 1     } } }
    { 3dup  T{ effect f 3 { 0 1 2 0 1 2 } } }
    { rot   T{ effect f 3 { 1 2 0       } } }
    { -rot  T{ effect f 3 { 2 0 1       } } }
    { dupd  T{ effect f 2 { 0 0 1       } } }
    { swapd T{ effect f 3 { 1 0 2       } } }
    { nip   T{ effect f 2 { 1           } } }
    { 2nip  T{ effect f 3 { 2           } } }
    { tuck  T{ effect f 2 { 1 0 1       } } }
    { over  T{ effect f 2 { 0 1 0       } } }
    { pick  T{ effect f 3 { 0 1 2 0     } } }
    { swap  T{ effect f 2 { 1 0         } } }
} [ first2 define-shuffle ] each

\ >r [
    #>r dup node,
    1 0 pick node-inputs
    pop-d push-r
    0 1 rot node-outputs
] "infer" set-word-prop

\ >r { object } { } <effect> "infer-effect" set-word-prop

\ r> [
    check-r>
    #r> dup node,
    0 1 pick node-inputs
    pop-r push-d
    1 0 rot node-outputs
] "infer" set-word-prop

\ r> { } { object } <effect> "infer-effect" set-word-prop
