! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference.stack
USING: inference.dataflow inference.backend arrays generic
kernel math namespaces sequences words parser words quotations
assocs effects ;

: split-shuffle ( stack shuffle -- stack1 stack2 )
    effect-in length swap cut* ;

: load-shuffle ( stack shuffle -- )
    effect-in [ set ] 2each ;

: shuffled-values ( shuffle -- values )
    effect-out [ get ] map ;

: shuffle* ( stack shuffle -- newstack )
    [ [ load-shuffle ] keep shuffled-values ] with-scope ;

: shuffle ( stack shuffle -- newstack )
    [ split-shuffle ] keep shuffle* append ;

: infer-shuffle-inputs ( shuffle node -- )
    >r effect-in length 0 r> node-inputs ;

: shuffle-stacks ( shuffle -- )
    meta-d [ swap shuffle ] change ;

: infer-shuffle-outputs ( shuffle node -- )
    >r effect-out length 0 r> node-outputs ;

: infer-shuffle ( shuffle -- )
    dup effect-in ensure-values
    #shuffle
    2dup infer-shuffle-inputs
    over shuffle-stacks
    2dup infer-shuffle-outputs
    node, drop ;

: define-shuffle ( word shuffle -- )
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
} [ define-shuffle ] assoc-each

\ >r [ infer->r ] "infer" set-word-prop

\ r> [ infer-r> ] "infer" set-word-prop
