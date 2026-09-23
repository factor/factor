USING: kernel ui.gadgets ui.gadgets.tracks tools.test
math.rectangles accessors sequences namespaces ;
USE: ui.test

! Expected geometry below uses unscaled pixels.
f [


{ { 100 100 } } [
    vertical <track>
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim
] unscaled-ui-test unit-test

{ { 100 110 } } [
    vertical <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim
] unscaled-ui-test unit-test

{ { 10 10 } } [
    vertical <track>
        <gadget> { 10 10 } >>dim 1 track-add
        <gadget> { 10 10 } >>dim 0 track-add
    pref-dim
] unscaled-ui-test unit-test

{ { 10 30 } } [
    vertical <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unscaled-ui-test unit-test

{ { 10 40 } } [
    vertical <track>
        { 5 5 } >>gap
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unscaled-ui-test unit-test

{ V{ { 10.0 10.0 } { 10.0 80.0 } { 10.0 10.0 } } } [
    vertical <track>
        0 >>fill
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim 1 track-add
        <gadget> { 10 10 } >>dim f track-add
    { 10 100 } >>dim
    [ layout ] [ children>> [ dim>> ] map ] bi
] unscaled-ui-test unit-test

{ } [
    vertical <track>
        0 >>fill
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim dup "g1" set 1/2 track-add
        <gadget> { 10 10 } >>dim dup "g2" set f track-add
        <gadget> { 10 10 } >>dim 1/2 track-add
        <gadget> { 10 10 } >>dim f track-add
    { 10 100 } >>dim
    "track" set
] unscaled-ui-test unit-test

{ V{ { 10.0 10.0 } { 10.0 35.0 } { 10.0 10.0 } { 10.0 35.0 } { 10.0 10.0 } } }
[ "track" get [ layout ] [ children>> [ dim>> ] map ] bi ] unscaled-ui-test unit-test

{ V{ { 10.0 10.0 } { 10.0 80.0 } { 10.0 10.0 } } } [
    "g1" get unparent
    "g2" get unparent
    "track" get [ layout ] [ children>> [ dim>> ] map ] bi
] unscaled-ui-test unit-test

{ 3 } [ "track" get sizes>> length ] unscaled-ui-test unit-test
] with-ui-test-scale
