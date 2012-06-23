! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order sequences ;
IN: sequences.windowed

TUPLE: windowed-sequence { sequence sequence read-only } { n integer } ;

INSTANCE: windowed-sequence sequence

C: <windowed-sequence> windowed-sequence
        
: in-bound ( n sequence -- n' )
    [ drop 0 ] [ length ] bi clamp ; inline

: in-bounds ( a b sequence -- a' b' sequence )
    [ nip in-bound ]
    [ [ nip ] dip in-bound ]
    [ 2nip ] 3tri ;
    
M: windowed-sequence nth
    [ [ 1 + ] dip n>> [ - ] [ drop ] 2bi ]
    [ nip sequence>> in-bounds <slice> ] 2bi ;
    
M: windowed-sequence length
    sequence>> length ;