! Copyright (C) 2009, 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays effects fry generalizations kernel
macros math math.order sequences sequences.generalizations
stack-checker stack-checker.backend stack-checker.errors
stack-checker.values stack-checker.visitor words memoize ;
IN: combinators.smart

GENERIC: infer-known* ( known -- effect )

: infer-known ( value -- effect )
    known dup (literal-value?) [
        (literal) [ infer-literal-quot ] with-infer drop
    ] [ infer-known* ] if ;

IDENTITY-MEMO: inputs/outputs ( quot -- in out )
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

M: curried infer-known*
    quot>> infer-known dup [
        curry-effect
    ] [
        drop f
    ] if ;

M: composed infer-known*
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

: input<sequence ( seq quot -- )
    [ inputs firstn ] [ call ] bi ; inline

: input<sequence-unsafe ( seq quot -- )
    [ inputs firstn-unsafe ] [ call ] bi ; inline

: reduce-outputs ( quot operation -- )
    [ [ call ] [ [ drop ] compose outputs ] bi ] dip swap call-n ; inline

: sum-outputs ( quot -- obj )
    [ + ] reduce-outputs ; inline

: map-outputs ( quot mapper -- )
    [ drop call ] [ swap outputs ] 2bi napply ; inline

: map-reduce-outputs ( quot mapper reducer -- )
    [ '[ _ _ map-outputs ] ] dip reduce-outputs ; inline

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
