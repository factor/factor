IN: gadgets-launchpad
USING: gadgets-buttons gadgets-labels gadgets-layouts io kernel
memory namespaces sequences ;

: <launchpad> ( menu -- )
    [ first2 >r <label> r> <bevel-button> ] map make-pile ;

: default-launchpad
    {
        { "Listener" [ global [ "Hi" print ] bind drop ] }
        { "Browser" [ global [ "Hi" print ] bind drop ] }
        { "Inspector" [ global [ "Hi" print ] bind drop ] }
        { "Help" [ global [ "Hi" print ] bind drop ] }
        { "Tutorial" [ global [ "Hi" print ] bind drop ] }
        { "System" [ global [ "Hi" print ] bind drop ] }
        { "Save image" [ save ] }
        { "Exit" [ 0 exit ] }
    } <launchpad> ;
