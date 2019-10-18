! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-presentations
USING: arrays definitions gadgets gadgets-borders
gadgets-buttons gadgets-labels gadgets-theme
generic hashtables tools io kernel prettyprint sequences strings
styles words help math models namespaces ;

TUPLE: presentation object hook ;

: invoke-presentation ( presentation command -- )
    over dup presentation-hook call
    >r presentation-object r> invoke-command ;

: invoke-primary ( presentation -- )
    dup presentation-object primary-operation
    invoke-presentation ;

: invoke-secondary ( presentation -- )
    dup presentation-object secondary-operation
    invoke-presentation ;

: show-mouse-help ( presentation -- )
    dup presentation-object over show-summary button-update ;

C: presentation ( label object -- button )
    [ drop ] over set-presentation-hook
    [ set-presentation-object ] keep
    swap [ invoke-primary ] <roll-button>
    over set-gadget-delegate ;

M: presentation ungraft*
    dup hand-gadget get-global child? [ dup hide-status ] when
    delegate ungraft* ;

: operations-menu ( presentation -- )
    dup
    dup presentation-hook curry
    over presentation-object
    dup object-operations <commands-menu>
    swap show-menu ;

presentation H{
    { T{ button-down f f 3 } [ operations-menu ] }
    { T{ mouse-leave } [ dup hide-status button-update ] }
    { T{ mouse-enter } [ show-mouse-help ] }
    ! Responding to motion too allows nested presentations to
    ! display status help properly, when the mouse leaves a
    ! nested presentation and is still inside the parent, the
    ! parent doesn't receive a mouse-enter
    { T{ motion } [ show-mouse-help ] }
} set-gestures
