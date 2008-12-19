USING: kernel ui.gadgets ui.gadgets.tracks tools.test
       math.geometry.rect accessors ;
IN: ui.gadgets.tracks.tests

[ { 100 100 } ] [
    { 0 1 } <track>
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim    
] unit-test

[ { 100 110 } ] [
    { 0 1 } <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 100 100 } >>dim 1 track-add
    pref-dim
] unit-test

[ { 10 10 } ] [
    { 0 1 } <track>
        <gadget> { 10 10 } >>dim 1 track-add
        <gadget> { 10 10 } >>dim 0 track-add
    pref-dim
] unit-test

[ { 10 30 } ] [
    { 0 1 } <track>
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unit-test

[ { 10 40 } ] [
    { 0 1 } <track>
        { 5 5 } >>gap
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
        <gadget> { 10 10 } >>dim f track-add
    pref-dim
] unit-test