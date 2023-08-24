USING: accessors audio audio.engine combinators destructors
images.loader images.viewer init kernel namespaces
ui.gadgets ui.gadgets.buttons ui.gadgets.panes ;
FROM: ui.gadgets.buttons.private => border-button-theme ;
FROM: audio.engine.private => make-engine-current ;
IN: audio.gadget

TUPLE: audio-gadget < button
    play-label pause-label
    audio audio-clip state ;

<PRIVATE

CONSTANT: play-label-image-path "vocab:audio/gadget/play.png"
CONSTANT: pause-label-image-path "vocab:audio/gadget/pause.png"

SYMBOLS: play-label-image pause-label-image gadget-audio-engine ;

STARTUP-HOOK: [
    f play-label-image set-global
    f pause-label-image set-global
    f gadget-audio-engine set-global
]

: initialize-audio-gadgets ( -- )
    gadget-audio-engine get-global [
        play-label-image-path load-image
        play-label-image set-global

        pause-label-image-path load-image
        pause-label-image set-global

        <standard-audio-engine> dup start-audio*
        gadget-audio-engine set-global
    ] unless ;

SYMBOLS: playing paused ;

: relabel-audio-gadget ( audio-gadget label -- )
    [ drop clear-gadget ] [ add-gadget drop ] 2bi ;

: pause-audio-gadget ( audio-gadget -- )
    [ dup play-label>> relabel-audio-gadget ]
    [ paused swap state<< ]
    [ audio-clip>> pause-clip ] tri ;

: play-audio-gadget ( audio-gadget -- )
    [ dup pause-label>> relabel-audio-gadget ]
    [ playing swap state<< ]
    [ audio-clip>> play-clip ] tri ;

: click-audio-gadget ( audio-gadget -- )
    gadget-audio-engine get make-engine-current
    dup state>> {
        { playing [ pause-audio-gadget ] }
        { paused [ play-audio-gadget ] }
    } case ;

PRIVATE>

:: <audio-gadget> ( audio -- gadget )
    initialize-audio-gadgets
    play-label-image get-global <image-gadget> :> play-label
    pause-label-image get-global <image-gadget> :> pause-label
    play-label [ click-audio-gadget ] audio-gadget new-button
        border-button-theme
        audio >>audio
        paused >>state
        play-label >>play-label
        pause-label >>pause-label ;

M: audio-gadget graft*
    [ call-next-method ] [
        dup audio>>
        [ gadget-audio-engine get-global f ] dip f <static-audio-clip>
           >>audio-clip
        drop
    ] bi ;

M: audio-gadget ungraft*
    [ pause-audio-gadget ]
    [ audio-clip>> dispose ]
    [ call-next-method ] tri ;

: audio. ( audio -- )
    <audio-gadget> gadget. ;

M: audio content-gadget
    <audio-gadget> ;
