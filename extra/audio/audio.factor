USING: accessors alien arrays combinators kernel math openal ;
IN: audio

TUPLE: audio
    { channels integer }
    { sample-bits integer }
    { sample-rate integer }
    { size integer }
    { data c-ptr } ;

C: <audio> audio

ERROR: format-unsupported-by-openal audio ;

: openal-format ( audio -- format )
    dup [ channels>> ] [ sample-bits>> ] bi 2array {
        { { 1  8 } [ drop AL_FORMAT_MONO8    ] }
        { { 1 16 } [ drop AL_FORMAT_MONO16   ] }
        { { 2  8 } [ drop AL_FORMAT_STEREO8  ] }
        { { 2 16 } [ drop AL_FORMAT_STEREO16 ] }
        [ drop format-unsupported-by-openal ]
    } case ;

