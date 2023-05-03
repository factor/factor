! Copyright (C) 2023 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors color-picker colors colors.distances formatting
kernel math math.functions models random sequences ui ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.tracks
ui.tools.common ;

IN: color-picker-game

: random-color ( -- color )
    named-colors random named-color ;

TUPLE: color-picker-game < track ;

: color-score ( color1 color2 -- n )
    rgba-distance 1.0 swap - 100.0 * round >integer ;

: <match-button> ( -- button )
    "Match Color" [
        dup
        [ color-picker-game? ] find-parent
        children>> first children>> first2
        [ model>> compute-model ] bi@
        color-score "Your score: %d" sprintf
        over children>> first text<< relayout
    ] <border-button> ;

: <reset-button> ( -- button )
    "Random" [
        [ color-picker-game? ] find-parent
        children>> first children>> first
        model>> random-color swap set-model
    ] <border-button> ;

:: <color-picker-game> ( constructor -- gadget )
    vertical color-picker-game new-track
    white-interior { 5 5 } >>gap
    horizontal <track>
    random-color <model> <color-preview> 1/2 track-add
    constructor <color-sliders> swap over
    [ <color-preview> 1/2 track-add 1 track-add ]
    [ f track-add ]
    [ <color-status> f track-add ] tri*
    <match-button> f track-add
    <reset-button> f track-add ;

: <color-picker-games> ( -- gadget )
    [ <color-picker-game> ] <color-tabs> ;

MAIN-WINDOW: color-picker-game-window
    { { title "Color Picker Game" } }
    <color-picker-games> >>gadgets ;
