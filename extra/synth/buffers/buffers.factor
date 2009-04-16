! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types combinators kernel locals math math.ranges openal sequences sequences.merged specialized-arrays.uchar specialized-arrays.short ;
IN: synth.buffers

TUPLE: buffer sample-freq 8bit? id ;

: <buffer> ( sample-freq 8bit? -- buffer )
    f buffer boa ;

TUPLE: mono-buffer < buffer data ;

: <mono-buffer> ( sample-freq 8bit? -- buffer )
    f f mono-buffer boa ;

: <8bit-mono-buffer> ( sample-freq -- buffer ) t <mono-buffer> ;
: <16bit-mono-buffer> ( sample-freq -- buffer ) f <mono-buffer> ;

TUPLE: stereo-buffer < buffer left-data right-data ;

: <stereo-buffer> ( sample-freq 8bit? -- buffer )
    f f f stereo-buffer boa ;

: <8bit-stereo-buffer> ( sample-freq -- buffer ) t <stereo-buffer> ;
: <16bit-stereo-buffer> ( sample-freq -- buffer ) f <stereo-buffer> ;

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
    [ 128 * >integer 128 + ] uchar-array{ } map-as [ underlying>> ] [ length ] bi ;

: 16bit-buffer-data ( seq -- data size )
    [ 32768 * >integer ] short-array{ } map-as [ underlying>> ] [ byte-length ] bi ;

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

: telephone-sample-freq ( -- n ) 8000 ;
: half-sample-freq ( -- n ) 22050 ;
: cd-sample-freq ( -- n ) 44100 ;
: digital-sample-freq ( -- n ) 48000 ;
: professional-sample-freq ( -- n ) 88200 ;

: send-buffer ( buffer -- buffer )
    {
        [ gen-buffer dup [ >>id ] dip ]
        [ buffer-format ]
        [ buffer-data ]
        [ sample-freq>> alBufferData ]
    } cleave ;

: ?send-buffer ( buffer -- buffer )
    dup id>> [ send-buffer ] unless ;

