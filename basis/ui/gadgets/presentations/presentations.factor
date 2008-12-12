! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors definitions hashtables io kernel
sequences strings io.styles words help math models
namespaces quotations
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.labels ui.gadgets.menus ui.gadgets.worlds
ui.gadgets.status-bar ui.commands ui.operations ui.gestures ;
IN: ui.gadgets.presentations

TUPLE: presentation < button object hook ;

: invoke-presentation ( presentation command -- )
    over dup hook>> call
    [ object>> ] dip invoke-command ;

: invoke-primary ( presentation -- )
    dup object>> primary-operation
    invoke-presentation ;

: invoke-secondary ( presentation -- )
    dup object>> secondary-operation
    invoke-presentation ;

: show-mouse-help ( presentation -- )
    dup object>> over show-summary button-update ;

: <presentation> ( label object -- button )
    swap [ invoke-primary ] presentation new-button
        swap >>object
        [ drop ] >>hook
        roll-button-theme ;

M: presentation ungraft*
    dup hand-gadget get-global child? [ dup hide-status ] when
    call-next-method ;

: <operations-menu> ( presentation -- menu )
    [ object>> ]
    [ dup hook>> curry ]
    [ object>> object-operations ]
    tri <commands-menu> ;

: operations-menu ( presentation -- )
    dup <operations-menu> show-menu ;

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
