! (c)2009 Joe Groff bsd license
USING: accessors alarms audio audio.engine audio.loader calendar
destructors io kernel locals math math.functions math.ranges specialized-arrays
sequences random math.vectors ;
FROM: alien.c-types => short ;
SPECIALIZED-ARRAY: short
IN: audio.engine.test

TUPLE: noise-generator ;

M: noise-generator generator-audio-format
    drop 1 16 8000 ;
M: noise-generator generate-audio
    nip [ -1 shift [ -4096 4096 [a,b] random ] short-array{ } replicate-as ] keep ;

:: audio-engine-test ( -- )
    "vocab:audio/engine/test/loop.aiff" read-audio :> loop-sound
    "vocab:audio/engine/test/once.wav" read-audio :> once-sound
    0 :> i!
    <standard-audio-engine> :> engine
    engine start-audio*

    engine T{ audio-source f {  1.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } loop-sound t
        play-static-audio-clip :> loop-clip
    engine T{ audio-source f { -1.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } noise-generator new 8192 2
        play-streaming-audio-clip :> noise-clip

    [
        i 1 + i!
        i 0.05 * [ sin ] [ cos ] bi :> ( s c )
        loop-clip  source>> { c 0.0 s }          >>position drop
        noise-clip source>> { c 0.0 s } -2.0 v*n >>position drop

        i 50 mod zero? [
            engine T{ audio-source f { 0.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } once-sound f
            play-static-audio-clip drop
        ] when

        engine update-audio
    ] 20 milliseconds every :> alarm
    "Press Enter to stop the test." print
    readln drop
    alarm cancel-alarm
    engine dispose ;

MAIN: audio-engine-test
