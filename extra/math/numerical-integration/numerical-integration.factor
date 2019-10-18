USING: arrays kernel sequences namespaces math math.ranges
math.vectors vectors ;
IN: math.numerical-integration

SYMBOL: num-steps 180 num-steps set-global
: setup-simpson-range ( from to -- frange )
    2dup swap - num-steps get / <range> ;

: generate-simpson-weights ( seq -- seq )
    [
        { 1 4 } % length 2 / 2 - { 2 4 } <repetition> concat % 1 ,
    ] { } make ;

: integrate-simpson ( from to f -- x )
    >r setup-simpson-range r>
    dupd map dup generate-simpson-weights
    v. swap [ third ] keep first - 6 / * ;

