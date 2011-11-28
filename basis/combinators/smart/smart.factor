! Copyright (C) 2009, 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays effects fry generalizations kernel
macros math math.order sequences sequences.generalizations
stack-checker stack-checker.backend stack-checker.errors
stack-checker.values stack-checker.visitor words ;
IN: combinators.smart

GENERIC: infer-known* ( known -- effect )

: infer-known ( value -- effect )
    known dup (literal-value?) [
        (literal) [ infer-literal-quot ] with-infer drop
    ] [ infer-known* ] if ;

: inputs/outputs ( quot -- in out )
    infer [ in>> ] [ out>> ] bi [ length ] bi@ ;

: inputs ( quot -- n ) inputs/outputs drop ; inline

: outputs ( quot -- n ) inputs/outputs nip ; inline

\ inputs/outputs [
    peek-d
    infer-known [
        [ pop-d 1array #drop, ]
        [ [ in>> ] [ out>> ] bi [ length apply-object ] bi@ ] bi*
    ] [
        \ inputs/outputs dup required-stack-effect apply-word/effect
    ] if*
] "special" set-word-prop

! TODO: Handle the case where a nested call to infer-known returns f

M: curried infer-known*
    quot>> infer-known curry-effect ;

M: composed infer-known*
    [ quot1>> ] [ quot2>> ] bi
    [ infer-known ] bi@ compose-effects ;

M: declared-effect infer-known*
    known>> infer-known* ;

M: input-parameter infer-known* \ inputs/outputs unknown-macro-input ;

M: object infer-known* drop f ;

: drop-inputs ( quot -- newquot )
    inputs ndrop ; inline

: drop-outputs ( quot -- )
    [ call ] [ outputs ndrop ] bi ; inline

: keep-inputs ( quot -- )
    [ ] [ inputs ] bi nkeep ; inline

: output>sequence ( quot exemplar -- )
    [ [ call ] [ outputs ] bi ] dip nsequence ; inline

: output>array ( quot -- )
    { } output>sequence ; inline

: input<sequence ( seq quot -- )
    [ inputs firstn ] [ call ] bi ; inline

: input<sequence-unsafe ( seq quot -- )
    [ inputs firstn-unsafe ] [ call ] bi ; inline

MACRO: reduce-outputs ( quot operation -- newquot )
    [ [ ] [ outputs 1 [-] ] bi ] dip swap '[ @ _ _ call-n ] ;

MACRO: sum-outputs ( quot -- n )
    '[ _ [ + ] reduce-outputs ] ;

: map-outputs ( quot mapper -- )
    [ drop call ] [ swap outputs ] 2bi napply ; inline

: map-reduce-outputs ( quot mapper reducer -- )
    [ '[ _ _ map-outputs ] ] dip reduce-outputs ; inline

: append-outputs-as ( quot exemplar -- newquot )
    [ [ call ] [ outputs ] bi ] dip nappend-as ; inline

: append-outputs ( quot -- seq )
    { } append-outputs-as ; inline

: preserving ( quot -- )
    [ inputs ndup ] [ call ] bi ; inline

: dropping ( quot -- quot' )
    inputs '[ _ ndrop ] ; inline

: nullary ( quot -- quot' )
    dropping call ; inline

: smart-if ( pred true false -- quot )
    [ preserving ] 2dip if ; inline

: smart-when ( pred true -- quot )
    [ ] smart-if ; inline

: smart-unless ( pred false -- quot )
    [ [ ] ] dip smart-if ; inline

: smart-if* ( pred true false -- quot )
    [ [ [ preserving ] [ dropping ] bi ] dip swap ] dip compose if ; inline

: smart-when* ( pred true -- quot )
    [ ] smart-if* ; inline

: smart-unless* ( pred false -- quot )
    [ [ ] ] dip smart-if* ; inline

: smart-apply ( quot n -- quot )
    [ dup inputs ] dip mnapply ; inline
