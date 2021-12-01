! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers audio audio.engine audio.loader calendar
destructors io kernel locals math math.functions math.ranges specialized-arrays
sequences random math.vectors audio.engine ;


IN: sokoban.sound

:: play-beep ( -- )
    "vocab:sokoban/resources/once.wav" read-audio :> once-sound
    f 4 <audio-engine> :> engine
    engine start-audio*
    
    engine T{ audio-source f { 0.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } once-sound f
        play-static-audio-clip drop
    [ engine dispose ] 1 seconds later drop ;

:: play-music ( -- )
    "vocab:sokoban/resources/Tetris.wav" read-audio :> loop-sound
    f 4 <audio-engine> :> engine
    engine start-audio*
    
    engine T{ audio-source f { 0.0 0.0 0.0 } 1.0 { 0.0 0.0 0.0 } f } loop-sound t
        play-static-audio-clip drop ;
    

