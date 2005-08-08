! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic hashtables inference kernel
kernel-internals lists math math-internals strings vectors words ;

! A system for associating dataflow optimizers with words.

: optimizer-hooks ( node -- conditions )
    node-param "optimizer-hooks" word-prop ;

: optimize-hooks ( node -- node/t )
    dup optimizer-hooks cond ;

: define-optimizers ( word optimizers -- )
    { [ t ] [ drop t ] } add "optimizer-hooks" set-word-prop ;

: partial-eval? ( #call -- ? )
    dup node-param "stateless" word-prop [
        dup node-in-d [
            dup literal?
            [ 2drop t ] [ swap node-literals hash* ] ifte
        ] all-with?
    ] [
        drop f
    ] ifte ;

: literal-in-d ( #call -- inputs )
    dup node-in-d [
        dup literal?
        [ nip literal-value ] [ swap node-literals hash ] ifte
    ] map-with ;

: partial-eval ( #call -- node )
    dup literal-in-d over node-param
    [ with-datastack ] [
        [
            2drop t
        ] [
            inline-literals
        ] ifte
    ] catch ;

M: #call optimize-node* ( node -- node/t )
    {
        { [ dup node-param not ] [ node-successor ] }
        { [ dup partial-eval? ] [ partial-eval ] }
        { [ dup optimizer-hooks ] [ optimize-hooks ] }
        { [ dup inlining-class ] [ inline-method ] }
        { [ dup optimize-predicate? ] [ optimize-predicate ] }
        { [ t ] [ drop t ] }
    } cond ;
