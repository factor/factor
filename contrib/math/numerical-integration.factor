IN: math-contrib
USING: kernel sequences errors namespaces math vectors errors prettyprint io tools ;

: setup-range ( from to -- frange )
    >r step-size get r> <frange-no-endpt> ;

: integrate-rect ( from to f -- x )
    >r setup-range r>
    [ step-size get * + ] append >r 0 r> reduce ;

: integrate-trap ( from to f -- x )
    >r setup-range r>
    map dup 1 tail >r >vector dup pop drop r>
    [ + 2 / step-size get * ] 2map sum ;

SYMBOL: num-steps 180 num-steps set-global
: setup-simpson-range ( from to -- frange )
    [ swap - num-steps get /f ] 2keep swapd <frange> ;

: generate-simpson-weights ( seq -- seq )
    [ { 1 4 } % length 2 / 2 - [ { 2 4 } % ] times 1 , ] { } make ;

: integrate-simpson ( from to f -- x )
    >r setup-simpson-range r> dupd map dup generate-simpson-weights
    0 [ * + ] 2reduce swap [ third ] keep first - 6 / * ; 


: quadrature ( from to f -- x ) integrate-simpson ;

