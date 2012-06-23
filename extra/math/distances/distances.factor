! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.functions math.statistics math.vectors
sequences sequences.extras ;

IN: math.distances

: hamming-distance ( a b -- n )
    [ = not ] 2count ; inline

: minkowski-distance ( a b p -- n )
    [ [ [ - abs ] dip ^ ] curry 2map-sum ] keep recip ^ ;

: euclidian-distance ( a b -- n )
    2 minkowski-distance ; ! also math.vectors.distance

: manhattan-distance ( a b -- n )
    1 minkowski-distance ;

: chebyshev-distance ( a b -- n ) ! also chessboard-distance
    v- vabs supremum ;

: cosine-distance ( a b -- n )
    [ v* sum ] [ [ norm ] bi@ * ] 2bi / 1 swap - ;

: canberra-distance ( a b -- n )
    [ v- vabs ] [ [ vabs ] bi@ v+ ] 2bi v/ sum ;

: bray-curtis-distance ( a b -- n )
    [ v- ] [ v+ ] 2bi [ vabs sum ] bi@ / ;

: correlation-distance ( a b -- n )
    [ dup mean v-n ] bi@ [ v* sum ] [ [ norm ] bi@ * ] 2bi / 1 swap - ;
