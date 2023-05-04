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

: find-color-previews ( gadget -- preview1 preview2 )
    [ color-picker-game? ] find-parent
    children>> first children>> first2 ;

: color-score ( color1 color2 -- n )
    rgba-distance 1.0 swap - 100.0 * round >integer ;

: <match-button> ( -- button )
    "Match Color" [
        dup find-color-previews
        [ model>> compute-model ] bi@
        color-score "Your score: %d" sprintf
        over children>> first text<< relayout
    ] <border-button> ;

: <reset-button> ( -- button )
    "Random" [
        find-color-previews drop model>>
        random-color swap set-model
    ] <border-button> ;

:: <color-picker-game> ( constructor -- gadget )
    vertical color-picker-game new-track
        white-interior { 5 5 } >>gap

    random-color <model>        :> left-model
    constructor <color-sliders> :> ( sliders right-model )

    horizontal <track>
        left-model <color-preview>  1/2 track-add
        right-model <color-preview> 1/2 track-add
    1 track-add

    sliders                     f track-add
    right-model <color-status>  f track-add
    <match-button>              f track-add
    <reset-button>              f track-add ;

: <color-picker-games> ( -- gadget )
    [ <color-picker-game> ] <color-tabs> ;

MAIN-WINDOW: color-picker-game-window
    { { title "Color Picker Game" } }
    <color-picker-games> >>gadgets ;
