! Copyright (C) 2009, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators combinators.private
combinators.short-circuit compiler.tree.propagation.info
compiler.tree.propagation.inlining compiler.units continuations
effects fry kernel kernel.private namespaces quotations
sequences stack-checker stack-checker.dependencies
stack-checker.transforms words ;
IN: compiler.tree.propagation.call-effect

TUPLE: inline-cache value counter ;

: inline-cache-hit? ( word/quot ic -- ? )
    { [ value>> eq? ] [ nip counter>> effect-counter eq? ] } 2&& ; inline

: update-inline-cache ( word/quot ic -- )
    swap >>value effect-counter >>counter drop ; inline

SINGLETON: +unknown+

GENERIC: cached-effect ( quot -- effect )

M: object cached-effect drop +unknown+ ;

GENERIC: curry-effect* ( effect -- effect' )

M: +unknown+ curry-effect* ;

M: effect curry-effect* curry-effect ;

M: curried cached-effect
    quot>> cached-effect curry-effect* ;

: compose-effects* ( effect1 effect2 -- effect' )
    {
        { [ 2dup [ effect? ] both? ] [ compose-effects ] }
        { [ 2dup [ +unknown+ eq? ] either? ] [ 2drop +unknown+ ] }
    } cond ;

M: composed cached-effect
    [ first>> ] [ second>> ] bi [ cached-effect ] bi@ compose-effects* ;

: safe-infer ( quot -- effect )
    error get-global error-continuation get-global
    [ [ [ infer ] [ 2drop +unknown+ ] recover ] without-dependencies ] 2dip
    [ error set-global ] [ error-continuation set-global ] bi* ;

: cached-effect-valid? ( quot -- ? )
    cache-counter>> effect-counter eq? ; inline

: save-effect ( effect quot -- )
    swap >>cached-effect effect-counter >>cache-counter drop ;

M: quotation cached-effect
    dup cached-effect-valid?
    [ cached-effect>> ] [ [ safe-infer dup ] keep save-effect ] if ;

: call-effect-slow>quot ( effect -- quot )
    [ \ call-effect def>> curry ] [ add-effect-input ] bi
    '[ _ _ call-effect-unsafe ] ;

: call-effect-slow ( quot effect -- ) drop call ;

\ call-effect-slow [ call-effect-slow>quot ] 1 define-transform

\ call-effect-slow t "no-compile" set-word-prop

: call-effect-unsafe? ( quot effect -- ? )
    [ cached-effect ] dip
    over +unknown+ eq?
    [ 2drop f ] [ [ { effect } declare ] dip effect<= ] if ; inline

: call-effect-fast ( quot effect inline-cache -- )
    2over call-effect-unsafe?
    [ [ nip update-inline-cache ] [ drop call-effect-unsafe ] 3bi ]
    [ drop call-effect-slow ]
    if ; inline

: call-effect-ic ( quot effect inline-cache -- )
    3dup nip inline-cache-hit?
    [ drop call-effect-unsafe ]
    [ call-effect-fast ]
    if ; inline

: call-effect>quot ( effect -- quot )
    inline-cache new '[ drop _ _ call-effect-ic ] ;

: execute-effect-slow ( word effect -- )
    [ '[ _ execute ] ] dip call-effect-slow ; inline

: execute-effect-unsafe? ( word effect -- ? )
    over word-optimized?
    [ [ stack-effect { effect } declare ] dip effect<= ]
    [ 2drop f ]
    if ; inline

: execute-effect-fast ( word effect inline-cache -- )
    2over execute-effect-unsafe?
    [ [ nip update-inline-cache ] [ drop execute-effect-unsafe ] 3bi ]
    [ drop execute-effect-slow ]
    if ; inline

: execute-effect-ic ( word effect inline-cache -- )
    3dup nip inline-cache-hit?
    [ drop execute-effect-unsafe ]
    [ execute-effect-fast ]
    if ; inline

: execute-effect>quot ( effect -- quot )
    inline-cache new '[ drop _ _ execute-effect-ic ] ;

GENERIC: already-inlined-quot? ( quot -- ? )

M: curried already-inlined-quot? quot>> already-inlined-quot? ;

M: composed already-inlined-quot?
    {
        [ first>> already-inlined-quot? ]
        [ second>> already-inlined-quot? ]
    } 1|| ;

M: quotation already-inlined-quot? already-inlined? ;

GENERIC: add-quot-to-history ( quot -- )

M: curried add-quot-to-history quot>> add-quot-to-history ;

M: composed add-quot-to-history
    [ first>> add-quot-to-history ]
    [ second>> add-quot-to-history ] bi ;

M: quotation add-quot-to-history add-to-history ;

: last2 ( seq -- penultimate ultimate )
    2 tail* first2 ;

: top-two ( #call -- effect value )
    in-d>> last2 [ value-info ] bi@
    literal>> swap ;

ERROR: uninferable ;

: remove-effect-input ( effect -- effect' )
    ( -- object ) swap compose-effects ;

: (infer-value) ( value-info -- effect )
    dup literal?>> [
        literal>>
        [ callable? [ uninferable ] unless ]
        [ already-inlined-quot? [ uninferable ] when ]
        [ safe-infer dup +unknown+ = [ uninferable ] when ] tri
    ] [
        dup { [ slots>> empty? not ] [ class>> ] } 1&& {
            { \ curried [ slots>> third (infer-value) remove-effect-input ] }
            { \ composed [ slots>> last2 [ (infer-value) ] bi@ compose-effects ] }
            [ uninferable ]
        } case
    ] if ;

: infer-value ( value-info -- effect/f )
    '[ _ (infer-value) ] [ uninferable? ] ignore-error/f ;

: (value>quot) ( value-info -- quot )
    dup literal?>> [
        literal>> [ add-quot-to-history ] [ '[ drop @ ] ] bi
    ] [
        dup class>> {
            { \ curried [
                slots>> third (value>quot)
                '[ [ obj>> ] [ quot>> @ ] bi ]
            ] }
            { \ composed [
                slots>> last2 [ (value>quot) ] bi@
                '[ [ first>> @ ] [ second>> @ ] bi ]
            ] }
        } case
    ] if ;

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
