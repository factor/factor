IN: inference
USING: generic interpreter kernel lists math namespaces
sequences words ;

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
    #shuffle
    2dup infer-shuffle-inputs
    over shuffle-stacks
    tuck infer-shuffle-outputs
    node, ;

: shuffle>effect ( shuffle -- effect )
    dup shuffle-in-d [ drop object ] map
    swap shuffle-out-d [ drop object ] map 2list ;

: define-shuffle ( word shuffle -- )
    [ shuffle>effect "infer-effect" set-word-prop ] 2keep
    [ , \ infer-shuffle , ] [ ] make "infer" set-word-prop ;

{
    { drop  << shuffle f 1 0 {             } {   } >> }
    { 2drop << shuffle f 2 0 {             } {   } >> }
    { 3drop << shuffle f 3 0 {             } {   } >> }
    { dup   << shuffle f 1 0 { 0 0         } {   } >> }
    { 2dup  << shuffle f 2 0 { 0 1 0 1     } {   } >> }
    { 3dup  << shuffle f 3 0 { 0 1 2 0 1 2 } {   } >> }
    { rot   << shuffle f 3 0 { 1 2 0       } {   } >> }
    { -rot  << shuffle f 3 0 { 2 0 1       } {   } >> }
    { dupd  << shuffle f 2 0 { 0 0 1       } {   } >> }
    { swapd << shuffle f 3 0 { 1 0 2       } {   } >> }
    { nip   << shuffle f 2 0 { 1           } {   } >> }
    { 2nip  << shuffle f 3 0 { 2           } {   } >> }
    { tuck  << shuffle f 2 0 { 1 0 1       } {   } >> }
    { over  << shuffle f 2 0 { 0 1 0       } {   } >> }
    { pick  << shuffle f 3 0 { 0 1 2 0     } {   } >> }
    { swap  << shuffle f 2 0 { 1 0         } {   } >> }
    { >r    << shuffle f 1 0 {             } { 0 } >> }
    { r>    << shuffle f 0 1 { 0           } {   } >> }
} [ first2 define-shuffle ] each
