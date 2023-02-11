! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs continuations formatting kernel
math math.statistics parser sequences sorting spelling vocabs
vocabs.parser ;

IN: did-you-mean

: did-you-mean-restarts ( possibilities -- restarts )
    sort
    [ [ [ vocabulary>> ] [ name>> ] bi "Use %s:%s" sprintf ] keep ]
    { } map>assoc ;

: did-you-mean-restarts-with-defer ( name possibilities -- restarts )
    did-you-mean-restarts "Defer word in current vocabulary"
    rot 2array suffix ;

: <did-you-mean> ( name possibilities -- error restarts )
    [ drop \ no-word-error boa ]
    [ did-you-mean-restarts-with-defer ] 2bi ;

: did-you-mean-words ( name -- possibilities )
    all-words [ [ name>> ] histogram-by corrections ] keep
    [ name>> swap member? ] with filter ;

: did-you-mean ( name -- word )
    dup did-you-mean-words <did-you-mean>
    throw-restarts no-word-restarted ;
