USING: tools.test ui.gadgets.glass ui.gadgets.worlds ui.gadgets
math.rectangles namespaces accessors models sequences arrays
continuations kernel locals ui.gadgets.menus ui.gadgets.scrollers
ui.gestures ;
IN: ui.gadgets.glass.tests

{ } [
    <world-attributes>
    <gadget> 1array >>gadgets
    <world>
    { 1000 1000 } >>dim
    "w" set
] unit-test

{ } [ <gadget> "g" set ] unit-test

{ } [ "w" get "g" get { 0 0 } { 100 100 } <rect> show-glass ] unit-test

{ } [ "g" get hide-glass ] unit-test

{ f } [ "g" get parent>> parent>> ] unit-test

{ t } [ "w" get layers>> empty? ] unit-test

:: with-menu-hand-state ( quot -- )
    hand-loc get-global :> original-loc
    hand-clicked get-global :> original-clicked
    quot [
        original-loc hand-loc set-global
        original-clicked hand-clicked set-global
    ] finally ; inline

! A menu larger than its world must pass its constrained dimensions
! to the scroller viewport, while retaining its preferred dimensions.
{ { 100 100 } { 88.0 88.0 } { 312.0 412.0 } } [
    [
        <world-attributes> <gadget> 1array >>gadgets <world>
        { 100 100 } >>dim "small-world" set
        <gadget> { 300 400 } >>dim <scroller> "large-menu" set
        { 50 50 } hand-loc set-global
        "small-world" get "large-menu" get show-menu
        "small-world" get layout
        "large-menu" get [ dim>> ] [ viewport>> dim>> ] [ pref-dim ] tri
        "large-menu" get hide-glass
    ] with-menu-hand-state
] unit-test
