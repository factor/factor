! Copyright (C) 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types combinators kernel math
openal sequences sequences.merged specialized-arrays ;
SPECIALIZED-ARRAY: uchar
SPECIALIZED-ARRAY: short
IN: synth.buffers

TUPLE: buffer sample-freq 8-bit? id ;

: <buffer> ( sample-freq 8-bit? -- buffer )
    f buffer boa ;

TUPLE: mono-buffer < buffer data ;

: <mono-buffer> ( sample-freq 8-bit? -- buffer )
    f f mono-buffer boa ;

: <8-bit-mono-buffer> ( sample-freq -- buffer ) t <mono-buffer> ;
: <16-bit-mono-buffer> ( sample-freq -- buffer ) f <mono-buffer> ;

TUPLE: stereo-buffer < buffer left-data right-data ;

: <stereo-buffer> ( sample-freq 8-bit? -- buffer )
    f f f stereo-buffer boa ;

: <8-bit-stereo-buffer> ( sample-freq -- buffer ) t <stereo-buffer> ;
: <16-bit-stereo-buffer> ( sample-freq -- buffer ) f <stereo-buffer> ;

PREDICATE: 8-bit-buffer < buffer 8-bit?>> ;
PREDICATE: 16-bit-buffer < buffer 8-bit?>> not ;
INTERSECTION: 8-bit-mono-buffer 8-bit-buffer mono-buffer ;
INTERSECTION: 16-bit-mono-buffer 16-bit-buffer mono-buffer ;
INTERSECTION: 8-bit-stereo-buffer 8-bit-buffer stereo-buffer ;
INTERSECTION: 16-bit-stereo-buffer 16-bit-buffer stereo-buffer ;

GENERIC: buffer-format ( buffer -- format )
M: 8-bit-mono-buffer buffer-format drop AL_FORMAT_MONO8 ;
M: 16-bit-mono-buffer buffer-format drop AL_FORMAT_MONO16 ;
M: 8-bit-stereo-buffer buffer-format drop AL_FORMAT_STEREO8 ;
M: 16-bit-stereo-buffer buffer-format drop AL_FORMAT_STEREO16 ;

: 8-bit-buffer-data ( seq -- data size )
    [ 128 * >integer 128 + ] uchar-array{ } map-as [ underlying>> ] [ length ] bi ;

: 16-bit-buffer-data ( seq -- data size )
    [ 32768 * >integer ] short-array{ } map-as [ underlying>> ] [ byte-length ] bi ;

: stereo-data ( stereo-buffer -- left right )
    [ left-data>> ] [ right-data>> ] bi@ ;

: interleaved-stereo-data ( stereo-buffer -- data )
    stereo-data <2merged> ;

GENERIC: buffer-data ( buffer -- data size )
M: 8-bit-mono-buffer buffer-data data>> 8-bit-buffer-data ;
M: 16-bit-mono-buffer buffer-data data>> 16-bit-buffer-data ;
M: 8-bit-stereo-buffer buffer-data
    interleaved-stereo-data 8-bit-buffer-data ;
M: 16-bit-stereo-buffer buffer-data
    interleaved-stereo-data 16-bit-buffer-data ;

CONSTANT: telephone-sample-freq 8000
CONSTANT: half-sample-freq 22050
CONSTANT: cd-sample-freq 44100
CONSTANT: digital-sample-freq 48000
CONSTANT: professional-sample-freq 88200

: send-buffer ( buffer -- buffer )
    {
        [ gen-buffer dup [ >>id ] dip ]
        [ buffer-format ]
        [ buffer-data ]
        [ sample-freq>> alBufferData ]
    } cleave ;

: ?send-buffer ( buffer -- buffer )
    dup id>> [ send-buffer ] unless ;
