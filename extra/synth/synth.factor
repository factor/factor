! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.constants math.functions
sequences sequences.modified sequences.repeating ;
IN: synth

SLOT: sample-freq

MEMO: single-sine-wave ( samples/wave -- seq )
    [ <iota> ] [ pi 2 * swap / [ * sin ] curry ] bi map ;

: (sine-wave) ( samples/wave n-samples -- seq )
    [ single-sine-wave ] dip <cycles> ;

: sine-wave ( sample-freq freq seconds -- seq )
    pick * >integer [ /i ] dip (sine-wave) ;

: >sine-wave-buffer ( freq seconds buffer -- buffer )
    [ sample-freq>> -rot sine-wave ] keep swap >>data ;

: >silent-buffer ( seconds buffer -- buffer )
    [ sample-freq>> * >integer 0 <repetition> ] [ data<< ] [ ] tri ;

TUPLE: harmonic n amplitude ;
C: <harmonic> harmonic

TUPLE: note hz secs ;
C: <note> note

: harmonic-freq ( note harmonic -- freq )
    n>> swap hz>> * ;

:: note-harmonic-data ( harmonic note buffer -- data )
    buffer sample-freq>> note harmonic harmonic-freq note secs>> sine-wave
    harmonic amplitude>> <scaled> ;

: >note ( harmonics note buffer -- buffer )
    [ [ note-harmonic-data ] 2curry map <summed> ] [ data<< ] [ ] tri ;
