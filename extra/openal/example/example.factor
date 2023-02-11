! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar kernel openal openal.alut sequences threads ;
IN: openal.example

: play-hello ( -- )
    init-openal
    1 gen-sources
    first dup AL_BUFFER  alutCreateBufferHelloWorld set-source-param
    source-play
    1000 milliseconds sleep ;

: play-waveform ( waveshape freq phase duration -- )
    init-openal
    [
        [ 1 gen-sources first dup AL_BUFFER ] 4dip
        alutCreateBufferWaveform
        set-source-param
        source-play
    ] [ seconds sleep ] bi ;

: play-sine ( freq duration -- )
  [ ALUT_WAVEFORM_SINE ] 2dip [ 0 ] dip play-waveform ;

: (play-file) ( source -- )
    100 milliseconds sleep
    dup source-playing? [ (play-file) ] [ drop ] if ;

: play-file ( filename -- )
    init-openal
    create-buffer-from-file
    1 gen-sources
    first dup [ AL_BUFFER rot set-source-param ] dip
    dup source-play
    check-error
    (play-file) ;

: play-wav ( filename -- )
    init-openal
    create-buffer-from-wav
    1 gen-sources
    first dup [ AL_BUFFER rot set-source-param ] dip
    dup source-play
    check-error
    (play-file) ;
