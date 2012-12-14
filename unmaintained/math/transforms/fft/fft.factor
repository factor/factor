! Copyright (c) 2007 Hans Schmid.
! See http://factorcode.org/license.txt for BSD license.
USING: columns grouping kernel math math.constants math.functions math.vectors
    sequences ;
IN: math.transforms.fft

! Fast Fourier Transform

<PRIVATE

: n^v ( n v -- w ) [ ^ ] with map ;

: omega ( n -- n' )
    recip -2 pi i* * * exp ;

: twiddle ( seq -- seq' )
    dup length [ omega ] [ n^v ] bi v* ;

PRIVATE>

DEFER: fft

: two ( seq -- seq' )
    fft 2 v/n dup append ;

<PRIVATE

: even ( seq -- seq' ) 2 group 0 <column> ;
: odd ( seq -- seq' ) 2 group 1 <column> ;

: (fft) ( seq -- seq' )
    [ odd two twiddle ] [ even two ] bi v+ ;

PRIVATE>

: fft ( seq -- seq' )
    dup length 1 = [ (fft) ] unless ;

