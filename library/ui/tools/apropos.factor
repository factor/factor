IN: gadgets-apropos
USING: gadgets gadgets-editors gadgets-labels gadgets-panes
gadgets-scrolling gadgets-theme generic inspector kernel ;

TUPLE: apropos-gadget scroller input ;

: apropos-gadget-pane ( apropos -- pane )
    apropos-gadget-scroller scroller-gadget ;

: <apropos-prompt> ( -- gadget )
    "" <editor> dup faint-boundary ;

: show-apropos ( apropos -- )
    dup apropos-gadget-input commit-editor-text
    swap apropos-gadget-pane [ apropos ] with-pane ;

M: apropos-gadget gadget-gestures
    drop H{
        { T{ key-down f f "RETURN" } [ show-apropos ] }
    } ;

C: apropos-gadget ( -- )
    {
        { [ <pane> <scroller> ] set-apropos-gadget-scroller @center }
        { [ <apropos-prompt> ] set-apropos-gadget-input @top }
    } make-frame* ;

M: apropos-gadget pref-dim* drop { 350 200 0 } ;

M: apropos-gadget focusable-child* ( pane -- editor )
    apropos-gadget-input ;

M: apropos-gadget gadget-title drop "Apropos" ;
