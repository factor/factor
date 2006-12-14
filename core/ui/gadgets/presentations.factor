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
    dup presentation-object swap find-world
    [ world-status set-model ] [ drop ] if* ;

: hide-mouse-help ( presentation -- )
    find-world [ world-status f swap set-model ] when* ;

M: presentation ungraft* ( presentation -- )
    dup hide-mouse-help delegate ungraft* ;

C: presentation ( label object -- button )
    [ drop ] over set-presentation-hook
    [ set-presentation-object ] keep
    swap [ invoke-primary ] <roll-button>
    over set-gadget-delegate ;

: (command-button) ( target command -- label quot )
    dup command-name -rot
    [ invoke-command drop ] curry curry ;

: <command-button> ( target command -- button )
    (command-button) <bevel-button> ;

: <toolbar> ( target classes -- toolbar )
    [ commands "toolbar" swap hash ] map concat
    [ <command-button> ] map-with
    make-shelf ;

: <menu-item> ( hook target command -- button )
    rot >r
    (command-button) [ hand-clicked get find-world hide-glass ]
    r> 3append <roll-button> ;

: <commands-menu> ( hook target commands -- gadget )
    [ >r 2dup r> <menu-item> ] map 2nip make-filled-pile
    <default-border>
    dup menu-theme ;

: operations-menu ( presentation -- )
    dup
    dup presentation-hook curry
    over presentation-object
    dup object-operations <commands-menu>
    swap show-menu ;

presentation H{
    { T{ button-down f f 3 } [ operations-menu ] }
    { T{ mouse-leave } [ dup hide-mouse-help button-update ] }
    { T{ motion } [ dup show-mouse-help button-update ] }
} set-gestures

! Presentation help bar
: <presentation-help> ( model -- gadget )
    [ [ summary ] [ "" ] if* ] <filter> <label-control>
    dup reverse-video-theme ;
