! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii kernel locals math random
sequences sequences.extras vectors ;

IN: enigma

: <alphabet> ( -- seq )
    26 <iota> >array ;

: <cog> ( -- cog )
    <alphabet> randomize ;

: <reflector> ( -- reflector )
    <alphabet> dup length <iota> >vector [ dup empty? ] [
        [
            [ delete-random ] [ delete-random ] bi
            pick exchange
        ] keep
    ] until drop ;

TUPLE: enigma cogs prev-cogs reflector ;

: <enigma> ( num-cogs -- enigma )
    [ <cog> ] replicate dup clone <reflector> enigma boa ;

: reset-cogs ( enigma -- enigma )
    dup prev-cogs>> >>cogs ;

: special? ( n -- ? )
    [ 25 > ] [ 0 < ] bi or ;

:: encode ( text enigma -- cipher-text )
    0 :> ln!
    enigma cogs>> :> cogs
    enigma reflector>> :> reflector
    text >lower [
        CHAR: a mod dup special? [
            ln 1 + ln!
            cogs [ nth ] each reflector nth
            cogs reverse [ index ] each CHAR: a +
            cogs length <iota> [ 6 * 1 + ln mod zero? ] filter
            cogs [ unclip prefix ] change-nths
        ] unless
    ] map ;
