! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry generalizations kernel macros math.order
stack-checker math ;
IN: combinators.smart

MACRO: drop-outputs ( quot -- quot' )
    dup infer out>> '[ @ _ ndrop ] ;

MACRO: output>sequence ( quot exemplar -- newquot )
    [ dup infer out>> ] dip
    '[ @ _ _ nsequence ] ;

: output>array ( quot -- newquot )
    { } output>sequence ; inline

MACRO: input<sequence ( quot -- newquot )
    [ infer in>> ] keep
    '[ _ firstn @ ] ;

MACRO: input<sequence-unsafe ( quot -- newquot )
    [ infer in>> ] keep
    '[ _ firstn-unsafe @ ] ;

MACRO: reduce-outputs ( quot operation -- newquot )
    [ dup infer out>> 1 [-] ] dip n*quot compose ;

: sum-outputs ( quot -- n )
    [ + ] reduce-outputs ; inline

MACRO: map-reduce-outputs ( quot mapper reducer -- newquot )
    [ dup infer out>> ] 2dip
    [ swap '[ _ _ napply ] ]
    [ [ 1 [-] ] dip n*quot ] bi-curry* bi
    '[ @ @ @ ] ;

MACRO: append-outputs-as ( quot exemplar -- newquot )
    [ dup infer out>> ] dip '[ @ _ _ nappend-as ] ;

: append-outputs ( quot -- seq )
    { } append-outputs-as ; inline
