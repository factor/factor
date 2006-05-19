IN: gadgets-apropos
USING: gadgets gadgets-editors gadgets-labels gadgets-layouts
gadgets-panes gadgets-scrolling gadgets-theme generic inspector
kernel ;

TUPLE: apropos-gadget pane input ;

: apropos-pane ( gadget -- pane )
    [ apropos-gadget? ] find-parent apropos-gadget-pane ;

: add-apropos-gadget-pane ( pane gadget -- )
    2dup set-apropos-gadget-pane
    >r <scroller> r> @center frame-add ;

: add-apropos-gadget-input ( input gadget -- )
    2dup set-apropos-gadget-input @top frame-add ;

: <prompt> ( quot -- editor )
    "" <editor> [
        swap T{ key-down f f "RETURN" } set-action
    ] keep ;

: show-apropos ( editor -- )
    dup commit-editor-text
    swap apropos-pane [ apropos ] with-pane ;

C: apropos-gadget ( -- )
    <frame> over set-delegate
    <pane> over add-apropos-gadget-pane
    [ show-apropos ] <prompt> dup faint-boundary 
    over add-apropos-gadget-input ;

M: apropos-gadget pref-dim* drop { 350 200 0 } ;

M: apropos-gadget focusable-child* ( pane -- editor )
    apropos-gadget-input ;
