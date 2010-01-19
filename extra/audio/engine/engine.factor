! (c)2009 Joe Groff bsd license
USING: accessors alien audio classes.struct fry calendar alarms
combinators combinators.short-circuit destructors generalizations
kernel literals locals math openal sequences specialized-arrays strings ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS: c:float c:uchar c:uint ;
IN: audio.engine

TUPLE: audio-source
    { position initial: { 0.0 0.0 0.0 } }
    { gain float initial: 1.0 }
    { velocity initial: { 0.0 0.0 0.0 } }
    { relative? boolean initial: f } ;

TUPLE: audio-orientation
    { forward initial: { 0.0 0.0 -1.0 } }
    { up initial: { 0.0 1.0 0.0 } } ;

: orientation>float-array ( orientation -- float-array )
    [ forward>> first3 ]
    [ up>> first3 ] bi 6 float-array{ } nsequence ; inline

TUPLE: audio-listener
    { position initial: { 0.0 0.0 0.0 } }
    { gain float initial: 1.0 }
    { velocity initial: { 0.0 0.0 0.0 } }
    { orientation initial: T{ audio-orientation } } ;

TUPLE: audio-engine < disposable
    { voice-count integer }
    { buffer-size integer }
    { buffer-count integer }
    { al-device c-ptr }
    { al-context c-ptr }
    al-sources
    { listener audio-listener }
    { next-source integer }
    clips
    update-alarm ;

TUPLE: audio-clip < disposable
    { audio-engine audio-engine }
    { audio audio }
    { source audio-source }
    { loop? boolean }
    { al-source integer }
    { al-buffers uint-array }
    { next-data-offset integer } ;

ERROR: audio-device-not-found device-name ;
ERROR: audio-context-not-available device-name ;

:: <audio-engine> ( device-name voice-count buffer-size buffer-count -- engine )
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
            buffer-size >>buffer-size
            buffer-count >>buffer-count
    ] with-destructors ;

: <standard-audio-engine> ( -- engine )
    f 16 8192 2 <audio-engine> ;

<PRIVATE

: make-engine-current ( audio-engine -- )
    al-context>> alcMakeContextCurrent drop ; inline

: allocate-sources ( audio-engine -- sources )
    voice-count>> dup (uint-array) [ alGenSources ] keep ; inline

:: flush-source ( source -- )
    source alSourceStop
    0 c:<uint> :> dummy-buffer
    source AL_BUFFERS_PROCESSED get-source-param [
        source 1 dummy-buffer alSourceUnqueueBuffers
    ] times ;

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

:: (queue-clip-buffer) ( audio-clip al-buffer audio data size -- )
    al-buffer audio openal-format data size audio sample-rate>> alBufferData
    audio-clip al-source>> 1 al-buffer c:<uint> alSourceQueueBuffers

    audio-clip [ size + ] change-next-data-offset drop ; inline

:: queue-clip-buffer ( audio-clip al-buffer -- )
    audio-clip audio-engine>> :> audio-engine
    audio-engine buffer-size>> :> buffer-size
    audio-clip audio>> :> audio
    audio-clip next-data-offset>> :> next-data-offset
    audio size>> next-data-offset - :> remaining-audio

    {
        { [ remaining-audio 0 <= ] [
            audio-clip loop?>> [
                audio-clip 0 >>next-data-offset
                al-buffer queue-clip-buffer
            ] when
        ] }
        { [ remaining-audio buffer-size < ] [
            audio-clip loop?>> [
                audio data>>
                [ next-data-offset swap <displaced-alien> remaining-audio <direct-uchar-array> ]
                [ buffer-size remaining-audio - <direct-uchar-array> ] bi append :> data
                audio-clip al-buffer audio data buffer-size (queue-clip-buffer)

                audio-clip [ audio size>> mod ] change-next-data-offset drop
            ] [
                next-data-offset audio data>> <displaced-alien> :> data
                audio-clip al-buffer audio data remaining-audio (queue-clip-buffer)
            ] if
        ] }
        [
            next-data-offset audio data>> <displaced-alien> :> data
            audio-clip al-buffer audio data buffer-size (queue-clip-buffer)
        ]
    } cond ;

: update-listener ( audio-engine -- )
    listener>> {
        [ AL_POSITION swap position>> first3 alListener3f ]
        [ AL_GAIN swap gain>> alListenerf ]
        [ AL_VELOCITY swap velocity>> first3 alListener3f ]
        [ AL_ORIENTATION swap orientation>> orientation>float-array alListenerfv ]
    } cleave ;

: update-source ( audio-clip -- )
    [ al-source>> ] [ source>> ] bi {
        [ AL_POSITION swap position>> first3 alSource3f ]
        [ AL_GAIN swap gain>> alSourcef ]
        [ AL_VELOCITY swap velocity>> first3 alSource3f ]
        [ AL_SOURCE_RELATIVE swap relative?>> c:>c-bool alSourcei ]
    } 2cleave ;

:: update-audio-clip ( audio-clip -- )
    audio-clip update-source
    audio-clip al-source>> :> al-source
    0 c:<uint> :> buffer*

    al-source AL_SOURCE_STATE get-source-param AL_STOPPED =
    [ audio-clip dispose ] [
        al-source AL_BUFFERS_PROCESSED get-source-param [
            al-source 1 buffer* alSourceUnqueueBuffers
            audio-clip buffer* c:*uint queue-clip-buffer
        ] times
    ] if ;

: clip-sources ( clips -- length sources )
    [ length ] [ [ source>> ] uint-array{ } map-as ] bi ;

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
    dup '[ _ update-audio ] 20 milliseconds every >>update-alarm
    drop ;

: stop-audio ( audio-engine -- )
    dup al-sources>> [
        {
            [ make-engine-current ]
            [ update-alarm>> [ cancel-alarm ] when* ]
            [ clips>> clone [ dispose ] each ]
            [ al-sources>> free-sources ]
            [
                f >>al-sources
                f >>clips
                f >>update-alarm
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

:: (audio-clip) ( audio-engine audio source loop? -- audio-clip/f )
    audio-engine get-available-source :> al-source

    al-source [
        audio-engine buffer-count>> :> buffer-count
        buffer-count dup (uint-array) [ alGenBuffers ] keep :> al-buffers

        audio-clip new-disposable
            audio-engine >>audio-engine
            audio >>audio
            source >>source
            loop? >>loop?
            al-source >>al-source
            al-buffers >>al-buffers
            0 >>next-data-offset :> clip
        al-buffers [ clip swap queue-clip-buffer ] each
        clip audio-engine clips>> push

        clip
    ] [ f ] if ;

M: audio-clip dispose*
    {
        [ al-source>> flush-source ]
        [ al-buffers>> [ length ] keep alDeleteBuffers ]
        [ dup audio-engine>> clips>> remove! drop ]
    } cleave ;

: play-clip ( audio-clip -- )
    [ update-source ]
    [ al-source>> alSourcePlay ] bi ;

: play-clips ( audio-clips -- )
    [ [ update-source ] each ]
    [ clip-sources alSourcePlayv ] bi ;

: <audio-clip> ( audio-engine audio source loop? -- audio-clip/f )
    (audio-clip) dup play-clip ;

: pause-clip ( audio-clip -- )
    al-source>> alSourcePause ;

: pause-clips ( audio-clip -- )
    clip-sources alSourcePausev ;

: stop-clip ( audio-clip -- )
    dispose ;

: stop-clips ( audio-clip -- )
    [ clip-sources alSourceStopv ]
    [ [ dispose ] each ] bi ;

: update-audio ( audio-engine -- )
    {
        [ make-engine-current ]
        [ update-listener ]
        [ clips>> [ update-audio-clip ] each ]
    } cleave ;

