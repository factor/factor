USING: accessors alien.c-types combinators kernel locals math
math.constants math.functions math.ranges openal sequences ;
IN: openal.waves

TUPLE: buffer bits channels sample-freq seq id ;

: <buffer> ( bits sample-freq seq -- buffer )
    ! defaults to 1 channel
    1 -rot gen-buffer buffer boa ;

: buffer-format ( buffer -- format )
    dup buffer-channels 1 = swap buffer-bits 8 = [
        AL_FORMAT_MONO8 AL_FORMAT_STEREO8
    ] [
        AL_FORMAT_MONO16 AL_FORMAT_STEREO16
    ] if ? ;

: buffer-data ( buffer -- data size )
    #! 8 bit data is integers between 0 and 255,
    #! 16 bit data is integers between -32768 and 32768
    #! size is in bytes
    [ seq>> ] [ bits>> ] bi 8 = [
        [ 128 * >integer 128 + ] map [ >c-uchar-array ] [ length ] bi
    ] [
        [ 32768 * >integer ] map [ >c-short-array ] [ length 2 * ] bi
    ] if ;

: send-buffer ( buffer -- )
    { [ id>> ] [ buffer-format ] [ buffer-data ] [ sample-freq>> ] } cleave
    alBufferData ;

: send-buffer* ( buffer -- id )
    [ send-buffer ] [ id>> ] bi ;

: (sine-wave-seq) ( samples/wave n-samples -- seq )
    pi 2 * rot / [ * sin ] curry map ;

: sine-wave-seq ( sample-freq freq seconds -- seq )
    pick * >integer [ / ] dip (sine-wave-seq) ;

: <sine-wave-buffer> ( bits sample-freq freq seconds -- buffer )
    >r dupd r> sine-wave-seq <buffer> ;

: <silent-buffer> ( bits sample-freq seconds -- buffer )
    dupd * >integer [ drop 0 ] map <buffer> ;

: play-sine-wave ( bits sample-freq freq seconds -- )
    init-openal
    <sine-wave-buffer> send-buffer*
    1 gen-sources first
    [ AL_BUFFER rot set-source-param ] [ source-play ] bi
    check-error ;

