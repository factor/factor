! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.labels ui.gadgets.menus
ui.gadgets.worlds hashtables io kernel prettyprint sequences
strings io.styles words help math models namespaces quotations
ui.commands ui.operations ui.gestures ;
IN: ui.gadgets.presentations

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

: <presentation> ( label object -- button )
    presentation construct-empty
    [ drop ] over set-presentation-hook
    [ set-presentation-object ] keep
    swap [ invoke-primary ] <roll-button>
    over set-gadget-delegate ;

M: presentation ungraft*
    dup hand-gadget get-global child? [ dup hide-status ] when
    delegate ungraft* ;

: <operations-menu> ( presentation -- menu )
    dup dup presentation-hook curry
    swap presentation-object
    dup object-operations <commands-menu> ;

: operations-menu ( presentation -- )
    dup <operations-menu> swap show-menu ;

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
