! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-workspace
USING: arrays gadgets gadgets-listener gadgets-buttons
gadgets-walker gadgets-help gadgets-walker sequences
gadgets-browser gadgets-books gadgets-frames kernel models
namespaces ;

TUPLE: workspace model ;

: workspace-tabs
    {
        { "Listener" listener-gadget [ <listener-gadget> ] }
        { "Walker" walker-gadget [ <walker-gadget> ] }
        { "Dictionary" browser [ <browser> ] } 
        { "Documentation" help-gadget [ <help-gadget> ] }
    } ;

: <workspace-book> ( workspace -- book )
    workspace-model
    workspace-tabs [ third ] map <book-control> ;

: <workspace-tabs> ( workspace -- tabs )
    workspace-model
    workspace-tabs dup length [ swap first 2array ] 2map
    <radio-box> ;

C: workspace
    0 <model> over set-workspace-model {
        { [ gadget get <workspace-tabs> ] f f @top }
        { [ gadget get <workspace-book> ] f f @center }
    } make-frame* ;
