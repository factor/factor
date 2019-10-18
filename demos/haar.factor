! Haar wavelet transform -- http://dmr.ath.cx/gfx/haar/
IN: haar
USING: sequences math kernel ;

: averages ( seq -- seq )
    [ first2 + 2 / ] map ;

: differences ( seq averages -- differences )
    >r 0 <column> r> [ - ] 2map ;

: haar-step ( seq -- differences averages )
    2 group dup averages [ differences ] keep ;

: haar ( seq -- seq )
    dup length 1 <= [ haar-step haar swap append ] unless ;

PROVIDE: demos/haar ;
