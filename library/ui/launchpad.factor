IN: gadgets-launchpad
USING: gadgets gadgets-buttons gadgets-labels gadgets-layouts
gadgets-listener io kernel memory namespaces sequences ;

: <launchpad> ( menu -- )
    [ first2 >r <label> r> <bevel-button> ] map make-pile
    1 over set-pack-fill ;

: default-launchpad
    {
        { "Listener" [ listener-window ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;

: launchpad-window ( -- )
    default-launchpad "Factor" simple-window ;
