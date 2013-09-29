! Copyright (C) 2013 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors calendar circular colors.constants colors.hsv
concurrency.semaphores generalizations kernel math
openal.example threads timers ui ui.gadgets ui.gadgets.worlds
ui.pens.solid ;
IN: rosetta-code.metronome

: bpm>duration ( bpm -- duration ) 60 swap / seconds ;

: blink-gadget ( gadget freq -- )
    1.0 1.0 1.0 <hsva>  <solid> >>interior relayout-1 ;

: blank-gadget ( gadget -- )
    COLOR: white <solid> >>interior relayout-1 ;

: play-note ( gadget freq -- )
    [ blink-gadget ] [ 0.3 play-sine blank-gadget ] 2bi ;

: open-metronome-window ( -- gadget )
    gadget new { 200 200 } >>pref-dim
    dup "Metronome" open-window yield ;

: metronome-loop ( gadget notes semaphore -- )
    [
        acquire [ play-note ] [ drop find-world handle>> ] 2bi
    ] curry with circular-loop ;

: start-metronome-timer ( bpm semaphore -- timer )
    [ release ] curry swap bpm>duration every ;

: metronome ( bpm notes -- )
    <circular> open-metronome-window
    swap 0 <semaphore>
    {
        [ 2nip start-metronome-timer ]
        [ metronome-loop drop ]
    } 4 ncleave
    stop-timer ;

! example usage: 60 { 440 220 330 } metronome
