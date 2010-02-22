! (c)2009 Joe Groff bsd license
USING: accessors assocs kernel locals sequences ui
ui.gadgets ui.gadgets.worlds ;
IN: window-controls-demo

CONSTANT: window-control-sets-to-test
    H{
        { "No controls" { } }
        { "Normal title bar" { normal-title-bar } }
        { "Small title bar" { small-title-bar close-button } }
        { "Close button" { normal-title-bar close-button } }
        { "Close and minimize buttons" { normal-title-bar close-button minimize-button } }
        { "Minimize button" { normal-title-bar minimize-button } }
        { "Close, minimize, and maximize buttons" { normal-title-bar close-button minimize-button maximize-button } }
        { "Resizable" { normal-title-bar close-button minimize-button maximize-button resize-handles } }
        { "Textured background" { normal-title-bar close-button minimize-button maximize-button resize-handles textured-background } }
    }

TUPLE: window-controls-demo-world < world
    windows ;

M: window-controls-demo-world end-world
    windows>> [ close-window ] each ;

M: window-controls-demo-world pref-dim*
    drop { 400 400 } ;

: attributes-template ( -- x )
    T{ world-attributes
        { world-class window-controls-demo-world }
    } clone ;

: window-controls-demo ( -- )
    attributes-template V{ } clone window-control-sets-to-test
    [| title attributes windows controls |
        f attributes
            title >>title
            controls >>window-controls
        open-window*
            windows >>windows
            windows push
    ] with with assoc-each ;

MAIN: window-controls-demo
