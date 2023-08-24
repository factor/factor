! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data audio calendar
combinators combinators.short-circuit destructors kernel
literals math openal sequences sequences.generalizations
specialized-arrays timers ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS: c:float c:uchar c:uint ;
IN: audio.engine

TUPLE: audio-source
    { position initial: { 0.0 0.0 0.0 } }
    { gain float initial: 1.0 }
    { velocity initial: { 0.0 0.0 0.0 } }
    { relative? boolean initial: f }
    { distance float initial: 1.0 }
    { rolloff float initial: 1.0 } ;

TUPLE: audio-orientation-state
    { forward initial: { 0.0 0.0 -1.0 } }
    { up initial: { 0.0 1.0 0.0 } } ;

C: <audio-orientation-state> audio-orientation-state

: orientation>float-array ( orientation -- float-array )
    [ forward>> first3 ]
    [ up>> first3 ] bi 6 float-array{ } nsequence ; inline

TUPLE: audio-listener
    { position initial: { 0.0 0.0 0.0 } }
    { gain float initial: 1.0 }
    { velocity initial: { 0.0 0.0 0.0 } }
    { orientation initial: T{ audio-orientation-state } } ;

GENERIC: audio-position ( source/listener -- position )
GENERIC: audio-gain ( source/listener -- gain )
GENERIC: audio-velocity ( source/listener -- velocity )
GENERIC: audio-relative? ( source -- relative? )
GENERIC: audio-distance ( source -- distance )
GENERIC: audio-rolloff ( source -- rolloff )
GENERIC: audio-orientation ( listener -- orientation )

M: object audio-position drop { 0.0 0.0 0.0 } ; inline
M: object audio-gain drop 1.0 ; inline
M: object audio-velocity drop { 0.0 0.0 0.0 } ; inline
M: object audio-relative? drop f ; inline
M: object audio-distance drop 1.0 ; inline
M: object audio-rolloff drop 1.0 ; inline
M: object audio-orientation drop T{ audio-orientation-state } ; inline

M: audio-source audio-position position>> ; inline
M: audio-source audio-gain gain>> ; inline
M: audio-source audio-velocity velocity>> ; inline
M: audio-source audio-relative? relative?>> ; inline
M: audio-source audio-distance distance>> ; inline
M: audio-source audio-rolloff rolloff>> ; inline

M: audio-listener audio-position position>> ; inline
M: audio-listener audio-gain gain>> ; inline
M: audio-listener audio-velocity velocity>> ; inline
M: audio-listener audio-orientation orientation>> ; inline

GENERIC: generate-audio ( generator -- c-ptr size )
GENERIC: generator-audio-format ( generator -- channels sample-bits sample-rate )

TUPLE: audio-engine < disposable
    { voice-count integer }
    { al-device c-ptr }
    { al-context c-ptr }
    al-sources
    listener
    { next-source integer }
    clips
    update-timer ;

TUPLE: audio-clip < disposable
    { audio-engine audio-engine }
    source
    { al-source integer } ;

TUPLE: static-audio-clip < audio-clip
    { al-buffer integer } ;

TUPLE: streaming-audio-clip < audio-clip
    generator
    { channels integer }
    { sample-bits integer }
    { sample-rate integer }
    { al-buffers uint-array }
    { done? boolean } ;

ERROR: audio-device-not-found device-name ;
ERROR: audio-context-not-available device-name ;

:: <audio-engine> ( device-name voice-count -- engine )
    [
        device-name alcOpenDevice :> al-device
        al-device [ device-name audio-device-not-found ] unless
        al-device |alcCloseDevice* drop

        al-device f alcCreateContext :> al-context
        al-context [ device-name audio-context-not-available ] unless
        al-context |alcDestroyContext drop

        al-context alcSuspendContext

        audio-engine new-disposable
            voice-count >>voice-count
            al-device >>al-device
            al-context >>al-context
    ] with-destructors ;

: <standard-audio-engine> ( -- engine )
    f 16 <audio-engine> ;

<PRIVATE

: make-engine-current ( audio-engine -- )
    al-context>> alcMakeContextCurrent drop ; inline

: allocate-sources ( audio-engine -- sources )
    voice-count>> dup c:uint (c-array) [ alGenSources ] keep ; inline

:: flush-source ( al-source -- )
    al-source alSourceStop
    0 c:uint <ref> :> dummy-buffer
    al-source AL_BUFFERS_PROCESSED get-source-param [
        al-source 1 dummy-buffer alSourceUnqueueBuffers
    ] times
    al-source AL_BUFFER 0 alSourcei ;

: free-sources ( sources -- )
    [ length ] keep alDeleteSources ; inline

:: (get-available-source) ( sources source# stop-source# -- next-source# al-source/f )
    source# sources nth :> al-source
    source# 1 + sources length mod :> next-source#
    al-source {
        [ AL_BUFFERS_PROCESSED get-source-param 0 = ]
        [ AL_BUFFERS_QUEUED get-source-param 0 = ]
        [ AL_SOURCE_STATE get-source-param { $ AL_INITIAL $ AL_STOPPED } member? ]
    } 1&&
    [ next-source# al-source ] [
        next-source# stop-source# =
        [ next-source# f ]
        [ sources next-source# stop-source# (get-available-source) ] if
    ] if ;

:: get-available-source ( audio-engine -- al-source/f )
    audio-engine [ al-sources>> ] [ next-source>> ] bi dup (get-available-source)
        :> ( next-source al-source )
    audio-engine next-source >>next-source drop
    al-source ;

:: queue-clip-buffer ( audio-clip al-buffer -- )
    audio-clip done?>> [
        audio-clip al-source>> :> al-source
        audio-clip generator>> :> generator
        generator generate-audio :> ( data size )

        size { [ not ] [ zero? ] } 1|| [
            audio-clip t >>done? drop
        ] [
            al-buffer audio-clip openal-format data size audio-clip sample-rate>> alBufferData
            al-source 1 al-buffer c:uint <ref> alSourceQueueBuffers
        ] if
    ] unless ;

: update-listener ( audio-engine -- )
    listener>> {
        [ AL_POSITION swap audio-position first3 alListener3f ]
        [ AL_GAIN swap audio-gain alListenerf ]
        [ AL_VELOCITY swap audio-velocity first3 alListener3f ]
        [ AL_ORIENTATION swap audio-orientation orientation>float-array alListenerfv ]
    } cleave ;

: update-source ( audio-clip -- )
    [ al-source>> ] [ source>> ] bi {
        [ AL_POSITION swap audio-position first3 alSource3f ]
        [ AL_GAIN swap audio-gain alSourcef ]
        [ AL_VELOCITY swap audio-velocity first3 alSource3f ]
        [ AL_SOURCE_RELATIVE swap audio-relative? c:>c-bool alSourcei ]
        [ AL_REFERENCE_DISTANCE swap audio-distance alSourcef ]
        [ AL_ROLLOFF_FACTOR swap audio-rolloff alSourcef ]
    } 2cleave ;

GENERIC: (update-audio-clip) ( audio-clip -- )

M: static-audio-clip (update-audio-clip)
    drop ;

M:: streaming-audio-clip (update-audio-clip) ( audio-clip -- )
    audio-clip al-source>> :> al-source
    0 c:uint <ref> :> buffer
    al-source AL_BUFFERS_PROCESSED get-source-param [
        al-source 1 buffer alSourceUnqueueBuffers
        audio-clip buffer c:uint deref queue-clip-buffer
    ] times ;

: update-audio-clip ( audio-clip -- )
    [ update-source ] [
        dup al-source>> AL_SOURCE_STATE get-source-param AL_STOPPED =
        [ dispose ] [ (update-audio-clip) ] if
    ] bi ;

: clip-al-sources ( clips -- length sources )
    [ length ] [ [ al-source>> ] uint-array{ } map-as ] bi ;

PRIVATE>

DEFER: update-audio

: start-audio* ( audio-engine -- )
    dup al-sources>> [ drop ] [
        {
            [ make-engine-current ]
            [ al-context>> alcProcessContext ]
            [
                dup allocate-sources >>al-sources
                0 >>next-source
                V{ } clone >>clips
                drop
            ]
            [ update-listener ]
        } cleave
    ] if ;

: start-audio ( audio-engine -- )
    dup start-audio*
    dup '[ _ update-audio ] 20 milliseconds every >>update-timer
    drop ;

: stop-audio ( audio-engine -- )
    dup al-sources>> [
        {
            [ make-engine-current ]
            [ update-timer>> [ stop-timer ] when* ]
            [ clips>> clone [ dispose ] each ]
            [ al-sources>> free-sources ]
            [
                f >>al-sources
                f >>clips
                f >>update-timer
                drop
            ]
            [ al-context>> alcSuspendContext ]
        } cleave
    ] [ drop ] if ;

M: audio-engine dispose*
    dup stop-audio
    [ [ alcDestroyContext ] when* f ] change-al-context
    [ [ alcCloseDevice*   ] when* f ] change-al-device
    drop ;

:: <static-audio-clip> ( audio-engine source audio loop? -- audio-clip/f )
    audio-engine get-available-source :> al-source

    al-source [
        1 0 c:uint <ref> [ alGenBuffers ] keep c:uint deref :> al-buffer
        al-buffer audio { [ openal-format ] [ data>> ] [ size>> ] [ sample-rate>> ] } cleave
            alBufferData

        al-source AL_BUFFER al-buffer alSourcei
        al-source AL_LOOPING loop? c:>c-bool alSourcei

        static-audio-clip new-disposable
            audio-engine >>audio-engine
            source >>source
            al-source >>al-source
            al-buffer >>al-buffer
            :> clip
        clip audio-engine clips>> push
        clip
    ] [ f ] if ;

:: <streaming-audio-clip> ( audio-engine source generator buffer-count -- audio-clip/f )
    audio-engine get-available-source :> al-source

    al-source [
        buffer-count dup c:uint (c-array) [ alGenBuffers ] keep :> al-buffers
        generator generator-audio-format :> ( channels sample-bits sample-rate )

        streaming-audio-clip new-disposable
            audio-engine >>audio-engine
            source >>source
            al-source >>al-source
            generator >>generator
            channels >>channels
            sample-bits >>sample-bits
            sample-rate >>sample-rate
            al-buffers >>al-buffers
            :> clip
        al-buffers [ clip swap queue-clip-buffer ] each
        clip audio-engine clips>> push
        clip
    ] [ generator dispose f ] if ;

M: audio-clip dispose*
    [ dup audio-engine>> clips>> remove! drop ]
    [ al-source>> flush-source ] bi ;

M: static-audio-clip dispose*
    [ call-next-method ]
    [ [ 1 ] dip al-buffer>> c:uint <ref> alDeleteBuffers ] bi ;

M: streaming-audio-clip dispose*
    [ call-next-method ]
    [ generator>> dispose ]
    [ al-buffers>> [ length ] keep alDeleteBuffers ] tri ;

: play-clip ( audio-clip -- )
    [ update-source ]
    [ al-source>> alSourcePlay ] bi ;

: play-clips ( audio-clips -- )
    [ [ update-source ] each ]
    [ clip-al-sources alSourcePlayv ] bi ;

: play-static-audio-clip ( audio-engine source audio loop? -- audio-clip/f )
    <static-audio-clip> dup [ play-clip ] when* ;

: play-streaming-audio-clip ( audio-engine source generator buffer-count -- audio-clip/f )
    <streaming-audio-clip> dup [ play-clip ] when* ;

: pause-clip ( audio-clip -- )
    al-source>> alSourcePause ;

: pause-clips ( audio-clips -- )
    clip-al-sources alSourcePausev ;

: stop-clip ( audio-clip -- )
    dispose ;

: stop-clips ( audio-clips -- )
    [ clip-al-sources alSourceStopv ]
    [ [ dispose ] each ] bi ;

: update-audio ( audio-engine -- )
    {
        [ make-engine-current ]
        [ update-listener ]
        [ clips>> clone [ update-audio-clip ] each ]
    } cleave ;
