! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors sequences byte-arrays bit-arrays math hints ;
IN: bit-sets

<PRIVATE

: bit-set-map ( seq1 seq2 quot -- seq )
    [ 2drop length>> ]
    [
        [
            [ [ length ] bi@ assert= ]
            [ [ underlying>> ] bi@ ] 2bi
        ] dip 2map
    ] 3bi bit-array boa ; inline

PRIVATE>

: bit-set-union ( seq1 seq2 -- seq ) [ bitor ] bit-set-map ;

HINTS: bit-set-union bit-array bit-array ;

: bit-set-intersect ( seq1 seq2 -- seq ) [ bitand ] bit-set-map ;

HINTS: bit-set-intersect bit-array bit-array ;

: bit-set-diff ( seq1 seq2 -- seq ) [ bitnot bitand ] bit-set-map ;

HINTS: bit-set-diff bit-array bit-array ;