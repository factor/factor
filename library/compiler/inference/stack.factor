IN: inference
USING: arrays generic kernel math namespaces
sequences words parser ;

: infer-shuffle-inputs ( shuffle node -- )
    >r shuffle-in length 0 r> node-inputs ;

: shuffle-stacks ( shuffle -- )
    meta-d [ swap shuffle ] change ;

: infer-shuffle-outputs ( shuffle node -- )
    >r shuffle-out length 0 r> node-outputs ;

: infer-shuffle ( shuffle -- )
    #shuffle dup node,
    2dup infer-shuffle-inputs
    over shuffle-stacks
    infer-shuffle-outputs ;

: shuffle>effect ( shuffle -- effect )
    dup shuffle-in swap shuffle-out <effect> ;

: define-shuffle ( word shuffle -- )
    [ "shuffle" set-word-prop ] 2keep
    [ shuffle>effect "infer-effect" set-word-prop ] 2keep
    [ , \ infer-shuffle , ] [ ] make "infer" set-word-prop ;

{
    { drop  T{ shuffle f 1 {             } } }
    { 2drop T{ shuffle f 2 {             } } }
    { 3drop T{ shuffle f 3 {             } } }
    { dup   T{ shuffle f 1 { 0 0         } } }
    { 2dup  T{ shuffle f 2 { 0 1 0 1     } } }
    { 3dup  T{ shuffle f 3 { 0 1 2 0 1 2 } } }
    { rot   T{ shuffle f 3 { 1 2 0       } } }
    { -rot  T{ shuffle f 3 { 2 0 1       } } }
    { dupd  T{ shuffle f 2 { 0 0 1       } } }
    { swapd T{ shuffle f 3 { 1 0 2       } } }
    { nip   T{ shuffle f 2 { 1           } } }
    { 2nip  T{ shuffle f 3 { 2           } } }
    { tuck  T{ shuffle f 2 { 1 0 1       } } }
    { over  T{ shuffle f 2 { 0 1 0       } } }
    { pick  T{ shuffle f 3 { 0 1 2 0     } } }
    { swap  T{ shuffle f 2 { 1 0         } } }
} [ first2 define-shuffle ] each

\ >r [
    #>r dup node,
    1 0 pick node-inputs
    pop-d push-r
    0 1 rot node-outputs
] "infer" set-word-prop

\ >r { object } { } <effect> "infer-effect" set-word-prop

\ r> [
    #r> dup node,
    0 1 pick node-inputs
    pop-r push-d
    1 0 rot node-outputs
] "infer" set-word-prop

\ r> { } { object } <effect> "infer-effect" set-word-prop
