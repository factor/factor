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
    pop-d
    [ 1array #drop, ] [ infer-known ] bi
    [ in>> ] [ out>> ] bi [ length apply-object ] bi@
] "special" set-word-prop

M: curried infer-known*
    quot>> infer-known curry-effect ;

M: composed infer-known*
    [ quot1>> ] [ quot2>> ] bi
    [ infer-known ] bi@ compose-effects ;

M: declared-effect infer-known*
    known>> infer-known* ;

M: input-parameter infer-known* \ inputs/outputs unknown-macro-input ;

M: object infer-known* \ inputs/outputs bad-macro-input ;

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
    [ dup outputs 1 [-] ] dip n*quot compose ;

: sum-outputs ( quot -- n )
    [ + ] reduce-outputs ; inline

: map-outputs ( quot mapper -- )
    [ drop call ] [ swap outputs ] 2bi napply ; inline

: map-reduce-outputs ( quot mapper reducer -- )
    [ '[ _ _ map-outputs ] ] dip reduce-outputs ; inline

MACRO: append-outputs-as ( quot exemplar -- newquot )
    [ dup outputs ] dip '[ @ _ _ nappend-as ] ;

MACRO: append-outputs ( quot -- seq )
    '[ _ { } append-outputs-as ] ;

MACRO: preserving ( quot -- )
    [ inputs ] keep '[ _ ndup @ ] ;

MACRO: dropping ( quot -- quot' )
    inputs '[ [ _ ndrop ] ] ;

MACRO: nullary ( quot -- quot' ) dropping ;

MACRO: smart-if ( pred true false -- quot )
    '[ _ preserving _ _ if ] ;

MACRO: smart-when ( pred true -- quot )
    '[ _ _ [ ] smart-if ] ;

MACRO: smart-unless ( pred false -- quot )
    '[ _ [ ] _ smart-if ] ;

MACRO: smart-if* ( pred true false -- quot )
    '[ _ [ preserving ] [ dropping ] bi _ swap _ compose if ] ;

MACRO: smart-when* ( pred true -- quot )
    '[ _ _ [ ] smart-if* ] ;

MACRO: smart-unless* ( pred false -- quot )
    '[ _ [ ] _ smart-if* ] ;

MACRO: smart-apply ( quot n -- quot )
    [ dup inputs ] dip '[ _ _ _ mnapply ] ;
