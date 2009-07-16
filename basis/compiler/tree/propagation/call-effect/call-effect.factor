! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.private effects fry
kernel kernel.private make sequences continuations quotations
words math stack-checker stack-checker.transforms
compiler.tree.propagation.info slots.private ;
IN: compiler.tree.propagation.call-effect

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

: call-effect-ic ( quot effect inline-cache -- )
    3dup nip cache-hit?
    [ drop call-effect-unsafe ]
    [ call-effect-fast ]
    if ; inline

: call-effect>quot ( effect -- quot )
    inline-cache new '[ drop _ _ call-effect-ic ] ;

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
    inline-cache new '[ drop _ _ execute-effect-ic ] ;

: last2 ( seq -- penultimate ultimate )
    2 tail* first2 ;

: top-two ( #call -- effect value )
    in-d>> last2 [ value-info ] bi@
    literal>> swap ;

ERROR: uninferable ;

: remove-effect-input ( effect -- effect' )
    (( -- object )) swap compose-effects ;

: (infer-value) ( value-info -- effect )
    dup class>> {
        { \ quotation [
            literal>> [ uninferable ] unless* cached-effect
            dup +unknown+ = [ uninferable ] when
        ] }
        { \ curry [
            slots>> third (infer-value)
            remove-effect-input
        ] }
        { \ compose [
            slots>> last2 [ (infer-value) ] bi@
            compose-effects
        ] }
        [ uninferable ]
    } case ;

: infer-value ( value-info -- effect/f )
    [ (infer-value) ]
    [ dup uninferable? [ 2drop f ] [ rethrow ] if ]
    recover ;

: (value>quot) ( value-info -- quot )
    dup class>> {
        { \ quotation [ literal>> '[ drop @ ] ] }
        { \ curry [
            slots>> third (value>quot)
            '[ [ obj>> ] [ quot>> @ ] bi ]
        ] }
        { \ compose [
            slots>> last2 [ (value>quot) ] bi@
            '[ [ first>> @ ] [ second>> @ ] bi ]
        ] }
    } case ;

: value>quot ( value-info -- quot: ( code effect -- ) )
    (value>quot) '[ drop @ ] ;

: call-inlining ( #call -- quot/f )
    top-two dup infer-value [
        pick effect<=
        [ nip value>quot ]
        [ drop call-effect>quot ] if
    ] [ drop call-effect>quot ] if* ;

\ call-effect [ call-inlining ] "custom-inlining" set-word-prop

: execute-inlining ( #call -- quot/f )
    top-two >literal< [
        2dup swap execute-effect-unsafe?
        [ nip '[ 2drop _ execute ] ]
        [ drop execute-effect>quot ] if
    ] [ drop execute-effect>quot ] if ;

\ execute-effect [ execute-inlining ] "custom-inlining" set-word-prop
