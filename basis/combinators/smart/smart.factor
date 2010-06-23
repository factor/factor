! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry generalizations sequences.generalizations
kernel macros math.order stack-checker math sequences ;
IN: combinators.smart

MACRO: drop-outputs ( quot -- quot' )
    dup outputs '[ @ _ ndrop ] ;

MACRO: keep-inputs ( quot -- quot' )
    dup inputs '[ _ _ nkeep ] ;

MACRO: output>sequence ( quot exemplar -- newquot )
    [ dup outputs ] dip
    '[ @ _ _ nsequence ] ;

MACRO: output>array ( quot -- newquot )
    '[ _ { } output>sequence ] ;

MACRO: input<sequence ( quot -- newquot )
    [ inputs ] keep
    '[ _ firstn @ ] ;

MACRO: input<sequence-unsafe ( quot -- newquot )
    [ inputs ] keep
    '[ _ firstn-unsafe @ ] ;

MACRO: reduce-outputs ( quot operation -- newquot )
    [ dup outputs 1 [-] ] dip n*quot compose ;

MACRO: sum-outputs ( quot -- n )
    '[ _ [ + ] reduce-outputs ] ;

MACRO: map-reduce-outputs ( quot mapper reducer -- newquot )
    [ dup outputs ] 2dip
    [ swap '[ _ _ napply ] ]
    [ [ 1 [-] ] dip n*quot ] bi-curry* bi
    '[ @ @ @ ] ;

MACRO: append-outputs-as ( quot exemplar -- newquot )
    [ dup outputs ] dip '[ @ _ _ nappend-as ] ;

MACRO: append-outputs ( quot -- seq )
    '[ _ { } append-outputs-as ] ;

MACRO: preserving ( quot -- )
    [ inputs ] keep '[ _ ndup @ ] ;

MACRO: boa-preserving ( tuple-class -- )
    '[ [ _ boa ] preserving ] ;

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
