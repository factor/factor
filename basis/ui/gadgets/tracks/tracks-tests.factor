USING: kernel ui.gadgets ui.gadgets.tracks tools.test
math.rectangles accessors sequences ;
IN: ui.gadgets.tracks.tests

[ { 100 100 } ] [
    vertical <track>
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim    
] unit-test

[ { 100 110 } ] [
    vertical <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim
] unit-test

[ { 10 10 } ] [
    vertical <track>
        <gadget> { 10 10 } >>dim 1 track-add
        <gadget> { 10 10 } >>dim 0 track-add
    pref-dim
] unit-test

[ { 10 30 } ] [
    vertical <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unit-test

[ { 10 40 } ] [
    vertical <track>
        { 5 5 } >>gap
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unit-test

[ V{ { 10 10 } { 10 80 } { 10 10 } } ] [
    vertical <track>
        0 >>fill
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim 1 track-add
        <gadget> { 10 10 } >>dim f track-add
    { 10 100 } >>dim
    [ layout ] [ children>> [ dim>> ] map ] bi
] unit-test

[ V{ { 10 10 } { 10 35 } { 10 10 } { 10 35 } { 10 10 } } ] [
    vertical <track>
        0 >>fill
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim 1/2 track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim 1/2 track-add
        <gadget> { 10 10 } >>dim f track-add
    { 10 100 } >>dim
    [ layout ] [ children>> [ dim>> ] map ] bi
] unit-test