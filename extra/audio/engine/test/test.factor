! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types audio.engine audio.loader
calendar destructors io kernel math math.functions math.vectors
random ranges sequences specialized-arrays timers ;
SPECIALIZED-ARRAY: short
IN: audio.engine.test

TUPLE: noise-generator ;

M: noise-generator generator-audio-format
    drop 1 16 8000 ;
M: noise-generator generate-audio
    drop
    4096 [ -4096 4096 [a..b] random ] short-array{ } replicate-as
    8192 ;
M: noise-generator dispose
    drop ;

:: audio-engine-test ( -- )
    "vocab:audio/engine/test/loop.aiff" read-audio :> loop-sound
    "vocab:audio/engine/test/once.wav" read-audio :> once-sound
    0 :> i!
    f 4 <audio-engine> :> engine
    engine start-audio*

    engine T{ audio-source f {  1.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } loop-sound t
        play-static-audio-clip :> loop-clip
    engine T{ audio-source f { -1.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } noise-generator new 2
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
    ] 20 milliseconds every :> timer
    "Press Enter to stop the test." print
    readln drop
    timer stop-timer
    engine dispose ;

MAIN: audio-engine-test
