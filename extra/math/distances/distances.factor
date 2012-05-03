! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel math math.functions sequences sequences.extras ;

IN: math.distances

: hamming-distance ( a b -- n )
    [ = not ] 2count ; inline

: minkowski-distance ( a b p -- n )
    [ [ [ - abs ] dip ^ ] curry 2map-sum ] keep recip ^ ;

: euclidian-distance ( a b -- n )
    2 minkowski-distance ; ! also math.vectors.distance

: manhattan-distance ( a b -- n )
    1 minkowski-distance ;

: chebyshev-distance ( a b -- n )
    [ - abs ] 2map supremum ;
