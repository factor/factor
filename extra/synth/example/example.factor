! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel make openal openal.alut sequences
synth synth.buffers ;
IN: synth.example

: play-sine-wave ( freq seconds sample-freq -- )
    init-openal
    <16-bit-mono-buffer> >sine-wave-buffer send-buffer id>>
    1 gen-sources first
    [ AL_BUFFER rot set-source-param ] [ source-play ] bi
    check-error ;

: test-instrument1 ( -- harmonics )
    [
        1 0.5 <harmonic> ,
        2 0.125 <harmonic> ,
        3 0.0625 <harmonic> ,
        4 0.03125 <harmonic> ,
    ] { } make ;

: test-instrument2 ( -- harmonics )
    [
        1 0.25 <harmonic> ,
        2 0.25 <harmonic> ,
        3 0.25 <harmonic> ,
        4 0.25 <harmonic> ,
    ] { } make ;

: sine-instrument ( -- harmonics )
    1 1 <harmonic> 1array ;

: test-note-buffer ( note -- )
    init-openal
    test-instrument2 swap cd-sample-freq <16-bit-mono-buffer>
    >note send-buffer id>>
    1 gen-sources first [ swap queue-buffer ] [ source-play ] bi
    check-error ;
