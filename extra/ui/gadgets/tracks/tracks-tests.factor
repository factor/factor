USING: kernel ui.gadgets ui.gadgets.tracks tools.test ;
IN: temporary

[ { 100 100 } ] [
    [
        <gadget> { 100 100 } over set-rect-dim 1 track,
    ] { 0 1 } make-track pref-dim
] unit-test

[ { 100 110 } ] [
    [
        <gadget> { 10 10 } over set-rect-dim f track,
        <gadget> { 100 100 } over set-rect-dim 1 track,
    ] { 0 1 } make-track pref-dim
] unit-test
