USING: math math.order kernel arrays byte-arrays sequences
colors.hsv benchmark.mandel.params ;
IN: benchmark.mandel.colors

: scale 255 * >fixnum ; inline

: scale-rgb ( r g b -- n ) [ scale ] tri@ 3byte-array ;

: sat 0.85 ; inline
: val 0.85 ; inline

: <color-map> ( nb-cols -- map )
    dup [
        360 * swap 1+ / sat val
        3array hsv>rgb first3 scale-rgb
    ] with map ;

: color-map ( -- map )
    max-iterations max-color min <color-map> ; foldable
