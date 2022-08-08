USING: math math.order kernel byte-arrays sequences
colors.hsv accessors colors benchmark.mandel.params ;
IN: benchmark.mandel.colors

: scale ( x -- y ) 255 * >fixnum ; inline

: scale-rgb ( rgba -- n )
    [ red>> scale ] [ green>> scale ] [ blue>> scale ] tri 3byte-array ;

CONSTANT: sat 0.85
CONSTANT: val 0.85

: <color-map> ( nb-cols -- map )
    [ <iota> ] keep '[
        360 * _ 1 + / sat val
        1 <hsva> >rgba scale-rgb
    ] map ;

: color-map ( -- map )
    max-iterations max-color min <color-map> ; foldable
