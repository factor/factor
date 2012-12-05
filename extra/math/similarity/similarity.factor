! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.statistics math.vectors sequences ;

IN: math.similarity

: euclidian-similarity ( a b -- n )
    v- norm 1 + recip ;

: pearson-similarity ( a b -- n )
    over length 3 < [ 2drop 1.0 ] [ full-corr 0.5 * 0.5 + ] if ;

: cosine-similarity ( a b -- n )
    [ v* sum ] [ [ norm ] bi@ * ] 2bi / 0.5 * 0.5 + ;
