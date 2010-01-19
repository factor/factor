USING: accessors alarms audio audio.engine audio.wav calendar
destructors io kernel locals math math.functions ;
IN: audio.engine.test

USE: prettyprint
:: audio-engine-test ( -- )
    "vocab:audio/engine/test/loop.wav" read-wav :> loop-sound
    "vocab:audio/engine/test/once.wav" read-wav :> once-sound
    0 :> i!
    <standard-audio-engine> :> engine
    engine dup . start-audio*
    engine loop-sound T{ audio-source f { 1.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } t <audio-clip>
        :> loop-clip

    [
        i 1 + i!
        i 0.05 * sin :> s
        loop-clip source>> { s 0.0 0.0 } >>position drop

        i 50 mod zero? [
            engine once-sound T{ audio-source f { 0.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } f
            <audio-clip> drop
        ] when

        engine update-audio
    ] 20 milliseconds every :> alarm
    "Press Enter to stop the test." print
    readln drop
    alarm cancel-alarm
    engine dispose ;


MAIN: audio-engine-test
