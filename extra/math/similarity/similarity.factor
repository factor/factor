! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: kernel math math.functions math.statistics math.vectors
sequences sequences.extras ;

IN: math.similarity

: euclidian-similarity ( a b -- n )
    v- norm 1 + recip ;

: pearson-similarity ( a b -- n )
    over length 3 < [ 2drop 1.0 ] [ population-corr 0.5 * 0.5 + ] if ;

: cosine-similarity ( a b -- n )
    [ vdot ] [ [ norm ] bi@ * ] 2bi / ;

<PRIVATE

: weighted-vdot ( w a b -- n )
    [ * * ] [ + ] 3map-reduce ;

: weighted-norm ( w a -- n )
    [ absq * ] [ + ] 2map-reduce ;

PRIVATE>

: weighted-cosine-similarity ( w a b -- n )
    [ weighted-vdot ]
    [ overd [ weighted-norm ] 2bi@ * ] 3bi / ;
