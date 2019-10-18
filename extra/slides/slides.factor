USING: arrays hashtables help.markup help.stylesheet io
io.styles kernel math models namespaces sequences ui ui.gadgets
ui.gadgets.books ui.gadgets.panes
ui.gestures ui.render ;
IN: slides

: stylesheet
    H{
        { default-style
            H{
                { font "sans-serif" }
                { font-size 36 }
                { wrap-margin 1000 }
            }
        }
        { code-style
            H{
                { font "monospace" }
                { font-size 36 }
                { page-color { 0.4 0.4 0.4 0.3 } }
            }
        }
        { snippet-style
            H{
                { font "monospace" }
                { font-size 36 }
                { foreground { 0.1 0.1 0.4 1 } }
            }
        }
        { table-content-style
            H{ { wrap-margin 800 } }
        }
        { list-style
            H{ { table-gap { 10 20 } } }
        }
        { bullet "\u00b7" }
    } ;

: $title ( string -- )
    [ H{ { font "sans-serif" } { font-size 48 } } format ] ($block) ;

: $divider ( -- )
    [
        <gadget>
        T{ gradient f { { 0.25 0.25 0.25 1.0 } { 1.0 1.0 1.0 0.0 } } }
        over set-gadget-interior
        { 800 10 } over set-gadget-dim
        { 1 0 } over set-gadget-orientation
        gadget.
    ] ($block) ;

: page-theme
    T{ gradient f { { 0.8 0.8 1.0 1.0 } { 0.8 1.0 1.0 1.0 } } }
    swap set-gadget-interior ;

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

TUPLE: slides ;

: <slides> ( slides -- gadget )
    [ <page> ] map 0 <model> <book>
    slides construct-gadget
    [ set-gadget-delegate ] keep ;

: change-page ( book n -- )
    over control-value + over gadget-children length rem
    swap gadget-model set-model ;

: next-page ( book -- ) 1 change-page ;

: prev-page ( book -- ) -1 change-page ;

\ slides H{
    { T{ key-down f f "DOWN" } [ next-page ] }
    { T{ key-down f f "UP" } [ prev-page ] }
} set-gestures

: slides-window ( slides -- )
    [ <slides> "Slides" open-window ] with-ui ;

MAIN: slides-window
