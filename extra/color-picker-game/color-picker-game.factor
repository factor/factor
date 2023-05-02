! Copyright (C) 2023 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors color-picker colors colors.distances formatting
kernel math models random sequences ui ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.tracks
ui.tools.common ;

IN: color-picker-game

: random-color ( -- color )
    named-colors random named-color ;

TUPLE: color-picker-game < track ;

: color-score ( color1 color2 -- n )
    rgba-distance 1.0 swap - 100.0 * 0.5 + >integer ;

: <match-button> ( -- button )
    "Match Color" [
        dup
        [ color-picker-game? ] find-parent
        children>> first children>> first2
        [ model>> compute-model ] bi@
        color-score "Your score: %d" sprintf
        over children>> first text<< relayout
    ] <border-button> ;

: <color-picker-game> ( -- gadget )
    vertical color-picker-game new-track
    white-interior { 5 5 } >>gap
    horizontal <track>
    random-color <model> <color-preview> 1/2 track-add
    \ <rgba> <color-sliders> swap over
    [ <color-preview> 1/2 track-add 1 track-add ]
    [ f track-add <match-button> f track-add ]
    [ <color-status> f track-add ] tri* ;

MAIN-WINDOW: color-picker-game-window
    { { title "Color Picker Game" } }
    <color-picker-game> { 5 5 } <border> >>gadgets ;
