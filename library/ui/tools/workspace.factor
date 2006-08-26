! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: gadgets-listener gadgets-walker gadgets-help
gadgets-walker ;

TUPLE: workspace model ;

: workspace-tabs
    {
        { "Listener" [ <listener-gadget> ] }
        { "Walker" [ <walker-gadget> ] }
        { "Dictionary" [ "Hello" <label> ] } 
        { "Documentation" [ <help-gadget> ] }
    } ;

: <workspace-book> ( workspace -- book )
    workspace-model
    workspace-tabs [ second ] map <book-control> ;

: <workspace-tabs> ( workspace -- tabs )
    workspace-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

C: workspace
    0 <model> over set-workspace-model {
        { [ gadget get <workspace-tabs> ] f f @top }
        { [ gadget get <workspace-book> ] f f @center }
    } make-frame*
