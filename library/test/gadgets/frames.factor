IN: temporary
USING: gadgets gadgets-labels gadgets-layouts kernel namespaces
test ;

[ "Hello world" ]
[
    <frame> "frame" set
    "Hello world" <label> "frame" get 1 2 frame-add
    "frame" get 1 2 frame-child label-text
] unit-test

[ @{ @{ 2 2 2 }@ @{ 3 3 3 }@ @{ 4 4 4 }@ }@ ] [
    @{
        @{ @{ 0 0 0 }@ @{ 1 1 1 }@ @{ 2 2 2 }@ }@
        @{ @{ 0 0 0 }@ @{ 3 3 3 }@ @{ 0 0 0 }@ }@
        @{ @{ 0 0 0 }@ @{ 0 0 0 }@ @{ 4 4 4 }@ }@
    }@ reduce-grid
] unit-test

[ @{ 9 9 9 }@ ] [
    @{
        @{ @{ 0 0 0 }@ @{ 1 1 1 }@ @{ 2 2 2 }@ }@
        @{ @{ 0 0 0 }@ @{ 3 3 3 }@ @{ 0 0 0 }@ }@
        @{ @{ 0 0 0 }@ @{ 0 0 0 }@ @{ 4 4 4 }@ }@
    }@ frame-pref-dim
] unit-test

[
    @{
        @{ @{ 1 2 0 }@ @{ 2 2 0 }@ @{ 3 2 0 }@ }@
        @{ @{ 1 4 0 }@ @{ 2 4 0 }@ @{ 3 4 0 }@ }@
    }@
] [
    @{ 1 2 3 }@ @{ 2 4 }@ frame-layout
] unit-test

: sized-gadget ( dim -- gadget )
    <gadget> [ set-rect-dim ] keep ;

[ @{ 90 120 0 }@ ]
[
    <frame> "frame" set
    @{ 10 20 0 }@ sized-gadget "frame" get 1 2 frame-add
    @{ 30 40 0 }@ sized-gadget "frame" get 2 0 frame-add
    @{ 50 60 0 }@ sized-gadget "frame" get 0 1 frame-add
    "frame" get pref-dim
] unit-test

[ @{ 180 210 0 }@ ]
[
    <frame> "frame" set
    @{ 10 20 0 }@ sized-gadget "frame" get @bottom frame-add
    @{ 30 40 0 }@ sized-gadget "frame" get @top-right frame-add
    @{ 50 60 0 }@ sized-gadget "frame" get @left frame-add
    @{ 100 150 0 }@ sized-gadget "frame" get @center frame-add
    "frame" get pref-dim
] unit-test

[ @{ 30 60 0 }@ ]
[
    <frame> "frame" set
    @{ 10 20 0 }@ sized-gadget "frame" get @top frame-add
    @{ 30 40 0 }@ sized-gadget "frame" get @center frame-add
    "frame" get pref-dim
] unit-test
