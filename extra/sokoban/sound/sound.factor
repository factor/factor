! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers audio audio.engine audio.loader calendar
destructors io kernel locals math math.functions ranges specialized-arrays
sequences random math.vectors literals ;


IN: sokoban.sound

: create-engine ( -- engine )
    f 10 <audio-engine> ;

:: play-beep ( engine -- )
    $[ "vocab:sokoban/resources/once.wav" read-audio ] :> once-sound
    engine start-audio*
    
    engine T{ audio-source f { 0.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } once-sound f
        play-static-audio-clip drop ;
