! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.private effects fry
kernel kernel.private make sequences continuations quotations
stack-checker stack-checker.transforms words math ;
IN: stack-checker.call-effect

! call( and execute( have complex expansions.

! call( uses the following strategy:
! - Inline caching. If the quotation is the same as last time, just call it unsafely
! - Effect inference. Infer quotation's effect, caching it in the cached-effect slot,
!   and compare it with declaration. If matches, call it unsafely.
! - Fallback. If the above doesn't work, call it and compare the datastack before
!   and after to make sure it didn't mess anything up.

! execute( uses a similar strategy.

TUPLE: inline-cache value ;

: cache-hit? ( word/quot ic -- ? )
    [ value>> eq? ] [ value>> ] bi and ; inline

SINGLETON: +unknown+

GENERIC: cached-effect ( quot -- effect )

M: object cached-effect drop +unknown+ ;

GENERIC: curry-effect ( effect -- effect' )

M: +unknown+ curry-effect ;

M: effect curry-effect
    [ in>> length ] [ out>> length ] [ terminated?>> ] tri
    pick 0 = [ [ 1+ ] dip ] [ [ 1- ] 2dip ] if
    effect boa ;

M: curry cached-effect
    quot>> cached-effect curry-effect ;

: compose-effects* ( effect1 effect2 -- effect' )
    {
        { [ 2dup [ effect? ] both? ] [ compose-effects ] }
        { [ 2dup [ +unknown+ eq? ] either? ] [ 2drop +unknown+ ] }
    } cond ;

M: compose cached-effect
    [ first>> ] [ second>> ] bi [ cached-effect ] bi@ compose-effects* ;

M: quotation cached-effect
    dup cached-effect>>
    [ ] [
        [ [ infer ] [ 2drop +unknown+ ] recover dup ] keep
        (>>cached-effect)
    ] ?if ;

: call-effect-unsafe? ( quot effect -- ? )
    [ cached-effect ] dip
    over +unknown+ eq?
    [ 2drop f ] [ effect<= ] if ; inline

: (call-effect-slow>quot) ( in out effect -- quot )
    [
        [ [ datastack ] dip dip ] %
        [ [ , ] bi@ \ check-datastack , ] dip
        '[ _ wrong-values ] , \ unless ,
    ] [ ] make ;

: call-effect-slow>quot ( effect -- quot )
    [ in>> length ] [ out>> length ] [ ] tri
    [ (call-effect-slow>quot) ] keep add-effect-input
    [ call-effect-unsafe ] 2curry ;

: call-effect-slow ( quot effect -- ) drop call ;

\ call-effect-slow [ call-effect-slow>quot ] 1 define-transform

\ call-effect-slow t "no-compile" set-word-prop

: call-effect-fast ( quot effect inline-cache -- )
    2over call-effect-unsafe?
    [ [ nip (>>value) ] [ drop call-effect-unsafe ] 3bi ]
    [ drop call-effect-slow ]
    if ; inline

\ call-effect [
    inline-cache new '[
        _
        3dup nip cache-hit? [
            drop call-effect-unsafe
        ] [
            call-effect-fast
        ] if
    ]
] 0 define-transform

\ call-effect t "no-compile" set-word-prop

: execute-effect-slow ( word effect -- )
    [ '[ _ execute ] ] dip call-effect-slow ; inline

: execute-effect-unsafe? ( word effect -- ? )
    over optimized? [ [ stack-effect ] dip effect<= ] [ 2drop f ] if ; inline

: execute-effect-fast ( word effect inline-cache -- )
    2over execute-effect-unsafe?
    [ [ nip (>>value) ] [ drop execute-effect-unsafe ] 3bi ]
    [ drop execute-effect-slow ]
    if ; inline

: execute-effect-ic ( word effect inline-cache -- )
    3dup nip cache-hit?
    [ drop execute-effect-unsafe ]
    [ execute-effect-fast ]
    if ; inline

: execute-effect>quot ( effect -- quot )
    inline-cache new '[ _ _ execute-effect-ic ] ;

\ execute-effect [ execute-effect>quot ] 1 define-transform

\ execute-effect t "no-compile" set-word-prop