! Copyright (C) 2009, 2011 Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators effects
generalizations kernel math sequences sequences.generalizations
stack-checker stack-checker.backend stack-checker.values
stack-checker.visitor words ;
IN: combinators.smart

GENERIC: infer-known* ( known -- effect )

: infer-known ( value -- effect )
    known dup (literal-value?) [
        (literal) [ infer-literal-quot ] with-infer drop
    ] [ infer-known* ] if ;

IDENTITY-MEMO: inputs/outputs ( quot -- in out )
    infer [ in>> ] [ out>> ] bi 2length ;

: inputs ( quot -- n ) inputs/outputs drop ; inline

: outputs ( quot -- n ) inputs/outputs nip ; inline

\ inputs/outputs [
    peek-d
    infer-known [
        [ pop-d 1array #drop, ]
        [ [ in>> ] [ out>> ] bi [ length apply-object ] bi@ ] bi*
    ] [
        \ inputs/outputs dup required-stack-effect apply-word/effect
        pop-d pop-d swap
        [ [ input-parameter swap set-known ] [ push-d ] bi ] bi@
    ] if*
] "special" set-word-prop

M: curried-effect infer-known*
    quot>> infer-known dup [
        curry-effect
    ] [
        drop f
    ] if ;

M: composed-effect infer-known*
    [ quot1>> ] [ quot2>> ] bi
    [ infer-known ] bi@
    2dup and [ compose-effects ] [ 2drop f ] if ;

M: declared-effect infer-known*
    known>> infer-known* ;

M: input-parameter infer-known* drop f ;

M: object infer-known* drop f ;

: drop-inputs ( quot -- )
    inputs ndrop ; inline

: drop-outputs ( quot -- )
    [ call ] [ outputs ndrop ] bi ; inline

: keep-inputs ( quot -- )
    [ ] [ inputs ] bi nkeep ; inline

: output>sequence ( quot exemplar -- seq )
    [ [ call ] [ outputs ] bi ] dip nsequence ; inline

: output>array ( quot -- array )
    { } output>sequence ; inline

MACRO: output>sequence-n ( quot exemplar n -- quot )
    3dup nip [ outputs ] dip - -rot
    '[ @ [ _ _ nsequence ] _ ndip ] ;

MACRO: output>array-n ( quot n -- array )
    '[ _ { } _ output>sequence-n ] ;

: cleave>array ( obj quots -- array )
    '[ _ cleave ] output>array ; inline

: cleave>sequence ( x seq exemplar -- array )
    [ '[ _ cleave ] ] dip output>sequence ; inline

: input<sequence ( seq quot -- )
    [ inputs firstn ] [ call ] bi ; inline

: input<sequence-unsafe ( seq quot -- )
    [ inputs firstn-unsafe ] [ call ] bi ; inline

: reduce-outputs ( quot operation -- )
    [ [ call ] [ [ drop ] compose outputs ] bi ] dip swap call-n ; inline

: sum-outputs ( quot -- n )
    [ + ] reduce-outputs ; inline

: map-outputs ( quot mapper -- )
    [ drop call ] [ swap outputs ] 2bi napply ; inline

MACRO: map-reduce-outputs ( quot mapper reducer -- quot )
    [ '[ _ _ map-outputs ] ] dip '[ _ _ reduce-outputs ] ;

: append-outputs-as ( quot exemplar -- seq )
    [ [ call ] [ outputs ] bi ] dip nappend-as ; inline

: append-outputs ( quot -- seq )
    { } append-outputs-as ; inline

: preserving ( quot -- )
    [ inputs ndup ] [ call ] bi ; inline

: dropping ( quot -- quot' )
    inputs '[ _ ndrop ] ; inline

: nullary ( quot -- )
    dropping call ; inline

: smart-if ( pred true false -- )
    [ preserving ] 2dip if ; inline

: smart-when ( pred true -- )
    [ ] smart-if ; inline

: smart-unless ( pred false -- )
    [ [ ] ] dip smart-if ; inline

: smart-if* ( pred true false -- )
    [ [ [ preserving ] [ dropping ] bi ] dip swap ] dip compose if ; inline

: smart-when* ( pred true -- )
    [ ] smart-if* ; inline

: smart-unless* ( pred false -- )
    [ [ ] ] dip smart-if* ; inline

: smart-apply ( quot n -- )
    [ dup inputs ] dip mnapply ; inline

: smart-with ( param obj quot -- obj curry )
    swapd dup inputs '[ [ _ -nrot ] dip call ] 2curry ; inline

MACRO: smart-reduce ( reduce-quots -- quot )
    unzip [ [ ] like ] bi@ dup length dup '[
        _ dip [ @ _ cleave-curry _ spread* ] each
    ] ;

MACRO: smart-map-reduce ( map-reduce-quots -- quot )
    [ keys ] [ [ [ ] concat-as ] [ ] map-as ] bi dup length dup '[
        [ first _ cleave ] keep
        [ @ _ cleave-curry _ spread* ]
        1 each-from
    ] ;

MACRO: smart-2reduce ( 2reduce-quots -- quot )
    unzip [ [ ] like ] bi@ dup length dup '[
        _ 2dip
        [ @ _ [ cleave-curry ] [ cleave-curry ] bi _ spread* ] 2each
    ] ;

MACRO: smart-2map-reduce ( 2map-reduce-quots -- quot )
    [ keys ] [ [ [ ] concat-as ] [ ] map-as ] bi dup length dup '[
        [ [ first ] bi@ _ 2cleave ] 2keep
        [ @ _ [ cleave-curry ] [ cleave-curry ] bi _ spread* ]
        1 2each-from
    ] ;

: smart-loop ( ..a quot: ( ..a -- ..b ? ) -- ..b )
    dup outputs [ ndrop ] curry while* ; inline
