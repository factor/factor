! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: bit-arrays combinators.short-circuit grouping kernel math
math.functions math.order math.statistics math.vectors sequences
sequences.extras sets ;

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

:: jaro-similarity ( a b -- n )
    a b 2dup [ length ] bi@ 2dup < [ [ swap ] 2bi@ ] when :> ( str1 str2 len1 len2 )
    len1 len2 max 2/ 1 [-] :> delta
    len2 <bit-array> :> flags

    str1 [| ch1 idx1 |
        idx1 delta [-] idx1 delta + len2 min [| idx2 |
            {
                [ idx2 flags nth not ]
                [ idx1 str1 nth idx2 str2 nth = ]
            } 0&& dup [ t idx2 flags set-nth ] when
        ] find-integer-from
    ] filter-index :> matches

    matches length :> #matches
    #matches dup zero? [
        drop
        0 :> #transpositions!
        0 :> idx1!
        str2 [| ch2 idx2 |
            idx2 flags nth [
                ch2 idx1 matches nth = [
                    #transpositions 1 + #transpositions!
                ] unless idx1 1 + idx1!
            ] when
        ] each-index

        #matches len1 /f #matches len2 /f +
        #matches #transpositions 2/ - #matches /f + 3 /
    ] unless ;

:: jaro-winkler-similarity ( a b -- n )
    a b jaro-similarity :> jaro
    a b min-length 4 min :> len
    a b [ len head-slice ] bi@ [ = ] 2count :> #common-prefix
    1 jaro - #common-prefix 0.1 * * jaro + ;

: trigram-similarity ( a b -- n )
    [ 3 clump ] bi@ [ intersect ] [ union ] 2bi [ length ] bi@ / ;
