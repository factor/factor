IN: gadgets-apropos
USING: gadgets gadgets-editors gadgets-labels gadgets-layouts
gadgets-panes gadgets-scrolling gadgets-theme generic inspector
kernel ;

TUPLE: apropos-gadget scroller input ;

: apropos-pane ( gadget -- pane )
    [ apropos-gadget? ] find-parent
    apropos-gadget-scroller scroller-gadget ;

: <prompt> ( quot -- editor )
    "" <editor> [
        swap T{ key-down f f "RETURN" } set-action
    ] keep ;

: show-apropos ( editor -- )
    dup commit-editor-text
    swap apropos-pane [ apropos ] with-pane ;

: <apropos-prompt> ( -- gadget )
    [ show-apropos ] <prompt> dup faint-boundary ;

C: apropos-gadget ( -- )
    {
        { [ <pane> <scroller> ] set-apropos-gadget-scroller @center }
        { [ <apropos-prompt> ] set-apropos-gadget-input @top }
    } make-frame* ;

M: apropos-gadget pref-dim* drop { 350 200 0 } ;

M: apropos-gadget focusable-child* ( pane -- editor )
    apropos-gadget-input ;

M: apropos-gadget gadget-title drop "Apropos" ;
