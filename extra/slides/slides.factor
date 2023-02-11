! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors fonts help.markup help.stylesheet
io.styles kernel literals math models namespaces parser ranges
sequences ui ui.gadgets ui.gadgets.books ui.gadgets.panes
ui.gestures ui.pens.gradient ;
IN: slides

CONSTANT: stylesheet
    H{
        { default-style
            H{
                { font-name $ default-sans-serif-font-name }
                { font-size $[ default-font-size 3 * ] }
                { wrap-margin $[ default-font-size 92 * ] }
            }
        }
        { code-style
            H{
                { font-name $ default-monospace-font-name }
                { font-size $[ default-font-size 3 * ] }
                { page-color T{ rgba f 0.4 0.4 0.4 0.3 } }
            }
        }
        { snippet-style
            H{
                { font-name $ default-monospace-font-name }
                { font-size $[ default-font-size 3 * ] }
                { foreground T{ rgba f 0.1 0.1 0.4 1 } }
            }
        }
        { table-content-style
            H{ { wrap-margin $[ default-font-size 83 * ] } }
        }
        { list-content-style
            H{ { wrap-margin $[ default-font-size 83 * ] } }
        }
        { list-style
            H{
                { table-gap ${ default-font-size 5/6 *
                               default-font-size 10/6 * }
                }
            }
        }
    }

: $title ( string -- )
    [
        H{
            { font-name $ default-sans-serif-font-name }
            { font-size $[ default-font-size 4 * ] }
        } format
    ] ($block) ;

: $divider ( -- )
    [
        <gadget>
            {
                T{ rgba f 0.25 0.25 0.25 1.0 }
                T{ rgba f 1.0 1.0 1.0 0.0 }
            } <gradient> >>interior
            ${ default-font-size 67 * default-font-size 5/6 * } >>dim
            { 1 0 } >>orientation
        gadget.
    ] ($block) ;

: page-theme ( gadget -- gadget )
    {
        T{ rgba f 0.8 0.8 1.0 1.0 }
        T{ rgba f 0.8 1.0 1.0 1.0 }
    } <gradient> >>interior ;

: <page> ( list -- gadget )
    [
        stylesheet clone [
            [ print-element ] with-default-style
        ] with-variables
    ] make-pane page-theme ;

: $slide ( element -- )
    unclip last-element off $title $divider last-element off $list ;

TUPLE: slides < book ;

: <slides> ( slides -- gadget )
    0 <model> slides new-book [ <page> add-gadget ] reduce ;

: change-page ( book n -- )
    over control-value + over children>> length rem
    swap set-control-value ;

: next-page ( book -- ) 1 change-page ;

: prev-page ( book -- ) -1 change-page ;

: strip-tease ( data -- seq )
    first3 2 over length [a..b] [ head 3array ] with with with map ;

SYNTAX: STRIP-TEASE:
    parse-definition strip-tease append! ;

\ slides H{
    { T{ button-down } [ request-focus ] }
    { T{ key-down f f " " } [ next-page ] }
    { T{ key-down f f "DOWN" } [ next-page ] }
    { T{ key-down f f "b" } [ prev-page ] }
    { T{ key-down f f "UP" } [ prev-page ] }
    { T{ key-down f f "q" } [ close-window ] }
    { T{ key-down f f "ESC" } [ close-window ] }
    { T{ key-down f f "f" } [ toggle-fullscreen ] }
} set-gestures

: slides-window ( slides title -- )
    '[ _ <slides> _ open-window ] with-ui ;
