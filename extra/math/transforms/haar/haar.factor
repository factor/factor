! Copyright (c) 2008 Slava Pestov, Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs columns grouping kernel math math.statistics math.vectors
    sequences ;
IN: math.transforms.haar

! Haar Wavelet Transform -- https://dmr.ath.cx/gfx/haar/

<PRIVATE

: averages ( seq -- seq' )
    [ mean ] map ;

: differences ( seq averages -- differences )
    [ 0 <column> ] dip v- ;

: haar-step ( seq -- differences averages )
    2 group dup averages [ differences ] keep ;

: rev-haar-step ( seq -- seq )
    halves [ v+ ] [ v- ] 2bi zip concat ;

PRIVATE>

: haar ( seq -- seq' )
    dup length 1 <= [ haar-step haar prepend ] unless ;

: rev-haar ( seq -- seq' )
    dup length 2 > [ halves swap rev-haar prepend ] when rev-haar-step ;
