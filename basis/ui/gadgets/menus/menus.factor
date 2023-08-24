! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.rectangles
math.vectors models namespaces opengl sequences sorting
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.glass ui.gadgets.packs ui.gadgets.worlds
ui.gadgets.wrappers ui.gestures ui.operations ui.pens
ui.pens.solid ui.theme ;
FROM: ui.gadgets.wrappers => wrapper ;

IN: ui.gadgets.menus

<PRIVATE

: (show-menu) ( owner menu -- )
    [ find-world ] dip hand-loc get-global point>rect show-glass ;

PRIVATE>

: show-menu ( owner menu -- )
    [ (show-menu) ] keep request-focus ;

TUPLE: menu-button < button ;

<PRIVATE

: align-left ( menu-button -- menu-button )
    { 0 1/2 } >>align ; inline

MEMO: menu-button-pen-boundary ( -- pen )
    f f roll-button-rollover-border <solid> dup dup <button-pen> ;

MEMO: menu-button-pen-interior ( -- pen )
    f f roll-button-selected-background <solid> f over <button-pen> ;

: menu-button-theme ( menu-button -- menu-button )
    menu-button-pen-boundary >>boundary
    menu-button-pen-interior >>interior
    align-left ; inline

: <menu-button> ( label quot -- menu-button )
    menu-button new-button menu-button-theme ; inline

PRIVATE>

GENERIC: <menu-item> ( target hook command -- menu-item )

M:: object <menu-item> ( target hook command -- menu-item )
    command command-name [
        hook call
        target command command-button-quot call
        hide-glass
    ] <menu-button> ;

<PRIVATE

TUPLE: separator-pen color ;

C: <separator-pen> separator-pen

M: separator-pen draw-interior
    color>> gl-color
    dim>> [ { 0 0.5 } v* ] [ { 1 0.5 } v* ] bi
    [ v>integer ] bi@ gl-line ;

: <menu-items> ( items -- gadget )
    [ <filled-pile> ] dip add-gadgets ;

PRIVATE>

SINGLETON: ----

M: ---- <menu-item>
    3drop
    <gadget>
        { 0 5 } >>dim
        menu-border-color <separator-pen> >>interior ;

TUPLE: menu < wrapper
    items ;

<PRIVATE

: find-menu ( menu-button -- menu )
    [ menu? ] find-parent ;

: activate-item ( menu-button -- )
    dup find-menu set-control-value ;

: inactivate-item ( menu-button -- )
    f swap find-menu set-control-value ;

: menu-buttons ( menu-items -- menu-buttons )
    children>> [ menu-button? ] filter ;

:: prepare-menu ( menu items -- )
    f <model> :> model
    items menu-buttons :> buttons
    buttons [ model add-connection ] each
    menu model >>model buttons >>items drop ;

PRIVATE>

M: menu-button model-changed
    swap value>> over = >>selected? relayout-1 ;

M: menu-button handle-gesture
    [
        {
            { [ over mouse-enter? ] [ nip activate-item ] }
            { [ over mouse-leave? ] [ nip inactivate-item ] }
            [ 2drop ]
        } cond
    ] 2keep call-next-method ;

<PRIVATE

:: next-item ( menu dir -- )
    menu [ items>> ] [ control-value ] bi :> ( items curr )
    curr [
        items length :> max
        curr items index :> indx
        indx dir + max rem items nth
    ] [ items first ] if menu set-control-value ;

: activate-menu-item ( menu -- )
    control-value [
        dup quot>> ( button -- ) call-effect
    ] when* ;

PRIVATE>

menu H{
    { T{ key-down f f "ESC" } [ hide-glass ] }
    { T{ key-down f f "DOWN" } [ 1 next-item ] }
    { T{ key-down f f "UP" } [ -1 next-item ] }
    { T{ key-down f f "RET" } [ activate-menu-item ] }
} set-gestures

: <menu> ( gadgets -- menu )
    <menu-items> [
        { 0 3 } >>gap
        { 5 5 } <filled-border>
        menu-border-color <solid> >>boundary
        menu-background <solid> >>interior
        menu new-wrapper
    ] [ dupd prepare-menu ] bi ;

: <commands-menu> ( target hook commands -- menu )
    [ <menu-item> ] 2with map <menu> ;

: show-commands-menu ( target commands -- )
    [ dup [ ] ] dip <commands-menu> show-menu ;

: <operations-menu> ( target hook -- menu )
    over object-operations
    [ primary-operation? ] partition
    [ reverse ] [ [ command-name ] sort-by ] bi*
    { ---- } glue <commands-menu> ;

: show-operations-menu ( gadget target hook -- )
    <operations-menu> show-menu ;
