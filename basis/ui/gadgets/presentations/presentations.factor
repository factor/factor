! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel memoize namespaces ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.buttons.private
ui.gadgets.glass ui.gadgets.menus ui.gadgets.status-bar
ui.gadgets.worlds ui.gestures ui.operations ui.pens.solid ui.theme ;
IN: ui.gadgets.presentations

TUPLE: presentation < button object hook ;

TUPLE: presentation-menu < border presentation ;

: invoke-presentation ( presentation command -- )
    [ [ dup hook>> call( presentation -- ) ] [ object>> ] bi ] dip
    invoke-command ;

: invoke-primary ( presentation -- )
    dup object>> primary-operation
    invoke-presentation ;

: invoke-secondary ( presentation -- )
    dup object>> secondary-operation
    invoke-presentation ;

: show-mouse-help ( presentation -- )
    [ [ object>> ] keep show-summary ] [ button-update ] bi ;

: <presentation> ( label object -- button )
    [ [ invoke-primary ] presentation new-button ] dip
        >>object
        [ drop ] >>hook
        roll-button-theme ;

M: presentation ungraft*
    dup hand-gadget get-global child? [ dup hide-status ] when
    call-next-method ;

MEMO: selected-pen-boundary ( -- button-pen )
    roll-button-rollover-border <solid> dup dup f f <button-pen> ;

<PRIVATE
: setup-presentation ( presentation -- presentation )
    selected-pen-boundary >>boundary ;
PRIVATE>

: <presentation-menu> ( presentation target hook -- menu )
    <operations-menu> presentation-menu new-border
        swap >>presentation
        { 0 0 } >>size ;

: show-presentation-menu ( presentation -- )
    setup-presentation dup
    [ ] [ object>> ] [ dup hook>> curry ] tri
    <presentation-menu> show-menu ;

M: presentation-menu hide-glass-hook
    presentation>> button-pen-boundary >>boundary drop ;

presentation H{
    { T{ button-down f f 3 } [ show-presentation-menu ] }
    { mouse-leave [ [ hide-status ] [ button-update ] bi ] }
    { mouse-enter [ show-mouse-help ] }
    ! Responding to motion too allows nested presentations to
    ! display status help properly, when the mouse leaves a
    ! nested presentation and is still inside the parent, the
    ! parent doesn't receive a mouse-enter
    { motion [ show-mouse-help ] }
} set-gestures
