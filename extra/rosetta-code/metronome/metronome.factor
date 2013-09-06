! Copyright (C) 2013 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors calendar circular colors.constants colors.hsv
concurrency.semaphores continuations formatting fry
generalizations io.launcher kernel math sequences threads timers
ui ui.gadgets ui.gadgets.worlds ui.pens.solid ;
IN: rosetta-code.metronome

! linux alsa..
! For debian, in package alsa-utils
: <wave-process> ( freq -- process )
    "speaker-test -t sine -f %d -p 20000" sprintf ;

: bpm>duration ( bpm -- duration ) 60 swap / seconds ;

: blink-gadget ( gadget freq -- )
    1.0 1.0 1.0 <hsva>  <solid> >>interior relayout-1 ;

: blank-gadget ( gadget -- )
    COLOR: white <solid> >>interior relayout-1 ;

: play-note ( gadget freq -- )
    [ dupd blink-gadget ] [ <wave-process> run-detached ] bi
    [ [ kill-process blank-gadget ] 2curry 300 milliseconds later drop ]
    [ [ wait-for-process ] ignore-errors drop ] bi ;

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
    [
        swap 0 <semaphore>
        {
            [ 2nip start-metronome-timer ]
            [ metronome-loop drop ]
        } 4 ncleave
    ]
    [ close-window stop-timer ] bi ;

! example usage: 60 { 440 220 330 } metronome
