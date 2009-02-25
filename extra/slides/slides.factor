! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables help.markup help.stylesheet io
io.styles kernel math models namespaces sequences ui ui.gadgets
ui.gadgets.books ui.gadgets.panes ui.gestures ui.render
parser accessors colors ;
IN: slides

CONSTANT: stylesheet
    H{
        { default-span-style
            H{
                { font "sans-serif" }
                { font-size 36 }
            }
        }
        { default-block-style
            H{
                { wrap-margin 1100 }
            }
        }
        { code-style
            H{
                { font "monospace" }
                { font-size 36 }
                { page-color T{ rgba f 0.4 0.4 0.4 0.3 } }
            }
        }
        { snippet-style
            H{
                { font "monospace" }
                { font-size 36 }
                { foreground T{ rgba f 0.1 0.1 0.4 1 } }
            }
        }
        { table-content-style
            H{ { wrap-margin 1000 } }
        }
        { list-style
            H{ { table-gap { 10 20 } } }
        }
        { bullet "\u0000b7" }
    }

: $title ( string -- )
    [ H{ { font "sans-serif" } { font-size 48 } } format ] ($block) ;

: $divider ( -- )
    [
        <gadget>
        {
            T{ rgba f 0.25 0.25 0.25 1.0 }
            T{ rgba f 1.0 1.0 1.0 0.0 }
        } <gradient> >>interior
        { 800 10 } >>dim
        { 1 0 } >>orientation
        gadget.
    ] ($block) ;

: page-theme ( gadget -- )
    { T{ rgba f 0.8 0.8 1.0 1.0 } T{ rgba f 0.8 1.0 1.0 1.0 } } <gradient>
    >>interior drop ;

: <page> ( list -- gadget )
    [
        stylesheet clone [
            [ print-element ] with-default-style
        ] bind
    ] make-pane
    dup page-theme ;

: $slide ( element -- )
    unclip $title
    $divider
    $list ;

TUPLE: slides < book ;

: <slides> ( slides -- gadget )
    [ <page> ] map 0 <model> slides new-book ;

: change-page ( book n -- )
    over control-value + over children>> length rem
    swap model>> set-model ;

: next-page ( book -- ) 1 change-page ;

: prev-page ( book -- ) -1 change-page ;

: (strip-tease) ( data n -- data )
    [ first3 ] dip head 3array ;

: strip-tease ( data -- seq )
    dup third length 1- [
        2 + (strip-tease)
    ] with map ;

: STRIP-TEASE:
    parse-definition strip-tease [ parsed ] each ; parsing

\ slides H{
    { T{ key-down f f "DOWN" } [ next-page ] }
    { T{ key-down f f "UP" } [ prev-page ] }
} set-gestures

: slides-window ( slides -- )
    [ <slides> "Slides" open-window ] with-ui ;
