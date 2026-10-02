! Copyright (C) 2005, 2009 Slava Pestov, 2015 Nicolas Pénet.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes kernel locals math math.order
sequences ui.baseline-alignment
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.menus ui.gadgets.tracks ui.pens
ui.pens.solid ui.theme ;
IN: ui.gadgets.toolbar

TUPLE: toolbar-command-button < button target command ;

TUPLE: toolbar < track overflow-button ;

<PRIVATE

: <toolbar-button-pen> ( -- pen )
    toolbar-background <solid> dup
    toolbar-button-pressed-background <solid> dup dup
    <button-pen> ;

: toolbar-button-theme ( gadget -- gadget )
    dup gadget-child border-button-label-theme
    horizontal >>orientation
    <toolbar-button-pen> >>interior
    dup dup interior>> pen-pref-dim >>min-dim
    { 10 6 } >>size ; inline

PRIVATE>

:: <toolbar-button> ( target gesture command -- button )
    command command-name
    target command command-button-quot
    '[ drop @ ] toolbar-command-button new-button toolbar-button-theme
    target >>target
    command >>command
    gesture gesture>tooltip >>tooltip ; inline

<PRIVATE

:: toolbar-view ( toolbar children -- track )
    toolbar clone
        children >>children
        children [ toolbar children>> index toolbar sizes>> nth ] map >>sizes ;

: toolbar-items ( toolbar -- children )
    [ children>> ] [ overflow-button>> ] bi '[ _ eq? not ] filter ;

: toolbar-command-buttons ( toolbar -- buttons )
    children>> [ toolbar-command-button? ] filter ;

: toolbar-extras ( toolbar -- children )
    toolbar-items [ toolbar-command-button? not ] filter ;

:: buttons-width ( buttons gap -- width )
    buttons [ pref-dim first ] map-sum
    buttons length 1 - 0 max gap * + ;

:: update-toolbar-overflow ( toolbar -- )
    toolbar gap>> first :> gap
    toolbar toolbar-command-buttons :> buttons
    toolbar toolbar-extras :> extras
    extras [ pref-dim first ] map-sum extras length gap * + :> extra-width
    toolbar dim>> first extra-width - 0 max :> available
    buttons gap buttons-width available > :> overflowing?
    toolbar overflow-button>> :> more
    more overflowing? >>visible? drop
    overflowing? [ available more pref-dim first - gap - 0 max ]
    [ available ] if :> remaining!
    t :> fits!
    buttons [| button |
        button pref-dim first :> width
        fits width remaining <= and fits!
        button fits >>visible? drop
        fits [ remaining width - gap - remaining! ] when
    ] each ;

: toolbar-overflow-menu ( toolbar -- menu )
    toolbar-command-buttons [ visible?>> not ] filter
    [ [ target>> ] [ command>> ] bi [ ] swap <menu-item> ] map <menu> ;

:: toolbar-layout-view ( toolbar -- track )
    toolbar toolbar children>> [ visible?>> ] filter toolbar-view :> view
    ! Elastic controls may shrink to zero when the menu button fills the row.
    view children>> view sizes>>
    [ [ drop 0 ] [ pref-dim first ] if ] 2map sum
    view children>> length 1 - 0 max view gap>> first * + :> minimum
    view view dim>> first minimum max view dim>> second 2array >>dim ;

: show-toolbar-overflow ( toolbar -- )
    dup overflow-button>> swap toolbar-overflow-menu show-menu ;

PRIVATE>

M: toolbar pref-dim*
    dup toolbar-items toolbar-view call-next-method ;

M: toolbar layout*
    dup update-toolbar-overflow
    toolbar-layout-view call-next-method ;

! Hidden buttons retain their parents but must not participate in hit testing.
M: toolbar children-on nip children>> [ visible?>> ] filter ;

:: <toolbar> ( target -- toolbar )
    horizontal toolbar new-track
        1 >>fill
        +baseline+ >>align
        { 5 5 } >>gap :> toolbar
    "toolbar" target class-of get-command-at commands>>
    [ target -rot <toolbar-button> toolbar swap f track-add drop ] assoc-each
    "..." [ drop toolbar show-toolbar-overflow ] <button>
        toolbar-button-theme f >>visible? :> more
    toolbar more >>overflow-button more f track-add ;

: format-toolbar ( toolbar -- toolbar )
    { 5 0 } <border>
    toolbar-background <solid> >>interior
    { 1 0 } >>fill ;

: add-toolbar ( track -- track )
    dup <toolbar> format-toolbar f track-add ;
