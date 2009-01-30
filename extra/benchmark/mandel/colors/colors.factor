USING: math math.order kernel arrays byte-arrays sequences
colors.hsv benchmark.mandel.params accessors colors ;
IN: benchmark.mandel.colors

: scale ( x -- y ) 255 * >fixnum ; inline

: scale-rgb ( rgba -- n )
    [ red>> scale ] [ green>> scale ] [ blue>> scale ] tri 3byte-array ;

: sat 0.85 ; inline
: val 0.85 ; inline

: <color-map> ( nb-cols -- map )
    dup [
        360 * swap 1+ / sat val
        1 <hsva> >rgba scale-rgb
    ] with map ;

: color-map ( -- map )
    max-iterations max-color min <color-map> ; foldable
