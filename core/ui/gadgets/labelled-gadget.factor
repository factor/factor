IN: gadgets
USING: arrays errors gadgets gadgets-buttons
gadgets-labels gadgets-theme gadgets-panes gadgets-scrolling
generic hashtables io kernel math models namespaces prettyprint
queues sequences test threads help sequences words timers ;

TUPLE: labelled-gadget content ;

C: labelled-gadget ( gadget title -- gadget )
    {
        { [ <label> dup reverse-video-theme ] f f @top }
        { f set-labelled-gadget-content f @center }
    } make-frame* ;

M: labelled-gadget focusable-child* labelled-gadget-content ;

: <labelled-pane> ( model quot title -- gadget )
    >r <pane-control> t over set-pane-scrolls? <scroller> r>
    <labelled-gadget> ;

: <close-box> ( quot -- button/f )
    gray close-box <polygon-gadget> swap <bevel-button> ;

: <title-label> <label> dup title-theme ;

: <title-bar> ( title quot -- gadget )
    [
        {
            { [ <close-box> ] f f @left }
            { [ <title-label> ] f f @center }
        } make-frame
    ] [
        <title-label>
    ] if* ;

TUPLE: closable-gadget content ;

C: closable-gadget ( gadget title quot -- gadget )
    {
        { [ <title-bar> ] f f @top }
        { f set-closable-gadget-content f @center }
    } make-frame* ;

M: closable-gadget focusable-child* closable-gadget-content ;
