! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types combinators kernel locals math math.constants math.functions math.ranges openal sequences sequences.merged sequences.repeating ;
IN: synth.buffers

TUPLE: buffer sample-freq 8bit? sent? id ;

: <buffer> ( sample-freq 8bit? -- buffer )
    f gen-buffer buffer boa ;

TUPLE: mono-buffer < buffer data ;

: <mono-buffer> ( sample-freq 8bit? -- buffer )
    f gen-buffer f mono-buffer boa ;

TUPLE: stereo-buffer < buffer left-data right-data ;

: <stereo-buffer> ( sample-freq 8bit? -- buffer )
    f gen-buffer f f stereo-buffer boa ;

PREDICATE: 8bit-buffer < buffer 8bit?>> ;
PREDICATE: 16bit-buffer < buffer 8bit?>> not ;
INTERSECTION: 8bit-mono-buffer 8bit-buffer mono-buffer ;
INTERSECTION: 16bit-mono-buffer 16bit-buffer mono-buffer ;
INTERSECTION: 8bit-stereo-buffer 8bit-buffer stereo-buffer ;
INTERSECTION: 16bit-stereo-buffer 16bit-buffer stereo-buffer ;

GENERIC: buffer-format ( buffer -- format )
M: 8bit-mono-buffer buffer-format drop AL_FORMAT_MONO8 ;
M: 16bit-mono-buffer buffer-format drop AL_FORMAT_MONO16 ;
M: 8bit-stereo-buffer buffer-format drop AL_FORMAT_STEREO8 ;
M: 16bit-stereo-buffer buffer-format drop AL_FORMAT_STEREO16 ;

: 8bit-buffer-data ( seq -- data size )
    [ 128 * >integer 128 + ] map [ >c-uchar-array ] [ length ] bi ;

: 16bit-buffer-data ( seq -- data size )
    [ 32768 * >integer ] map [ >c-short-array ] [ length 2 * ] bi ;

: stereo-data ( stereo-buffer -- left right )
    [ left-data>> ] [ right-data>> ] bi@ ;

: interleaved-stereo-data ( stereo-buffer -- data )
    stereo-data <2merged> ;

GENERIC: buffer-data ( buffer -- data size )
M: 8bit-mono-buffer buffer-data data>> 8bit-buffer-data ;
M: 16bit-mono-buffer buffer-data data>> 16bit-buffer-data ;
M: 8bit-stereo-buffer buffer-data
    interleaved-stereo-data 8bit-buffer-data ;
M: 16bit-stereo-buffer buffer-data
    interleaved-stereo-data 16bit-buffer-data ;

: telephone-sample-freq 8000 ;
: half-sample-freq 22050 ;
: cd-sample-freq 44100 ;
: digital-sample-freq 48000 ;
: professional-sample-freq 88200 ;

: send-buffer ( buffer -- buffer )
    {
        [ id>> ]
        [ buffer-format ]
        [ buffer-data ]
        [ sample-freq>> alBufferData ]
        [ t >>sent? ]
    } cleave ;

: ?send-buffer ( buffer -- buffer )
    dup sent?>> [ send-buffer ] unless ;

: (sine-wave) ( samples/wave n-samples -- seq )
    pi 2 * pick / swapd [ * sin ] curry map swap <repeating> ;

: sine-wave ( sample-freq freq seconds -- seq )
    pick * >integer [ /i ] dip (sine-wave) ;

: >sine-wave-buffer ( freq seconds buffer -- buffer )
    [ sample-freq>> -rot sine-wave ] keep swap >>data ;

: >silent-buffer ( seconds buffer -- buffer )
    tuck sample-freq>> * >integer 0 <repetition> >>data ;

: play-sine-wave ( freq seconds sample-freq -- )
    init-openal
    t <mono-buffer> >sine-wave-buffer send-buffer id>>
    1 gen-sources first
    [ AL_BUFFER rot set-source-param ] [ source-play ] bi
    check-error ;
