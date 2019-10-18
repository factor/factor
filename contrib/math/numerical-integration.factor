IN: math-contrib
USING: kernel sequences errors namespaces math vectors errors prettyprint io tools ;

: setup-range ( from to -- frange )
    step-size get swap <frange> ;

: integrate-rect ( from to f -- x )
    >r setup-range dup decrement-length r>
    [ step-size get * ] append map sum ;

: integrate-trap ( from to f -- x )
    >r setup-range r>
    map dup 1 tail >r >vector dup pop drop r>
    [ + 2 / step-size get * ] 2map sum ;


SYMBOL: num-steps 180 num-steps set ! simpsons
: setup-simpson-range ( from to -- frange )
    [ swap - num-steps get /f ] 2keep swapd <frange> ;

: generate-simpson-weights ( seq -- seq )
    length 2 / V{ 1 4 } clone swap 2 -
    [ { 2 4 } append ] times { 1 } append ;

: integrate-simpson ( from to f -- x )
    >r setup-simpson-range r> dupd map dup generate-simpson-weights
    [ * ] 2map sum swap [ third ] keep first - 6 / * ; 


: quadrature ( from to f -- x )
    integrate-simpson ;
