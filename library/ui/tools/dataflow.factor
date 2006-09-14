! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-dataflow
USING: namespaces arrays sequences io inference math kernel
generic prettyprint words gadgets opengl gadgets-panes
gadgets-labels gadgets-theme gadgets-presentations
gadgets-buttons gadgets-borders gadgets-scrolling
gadgets-frames gadgets-workspace optimizer models ;

: shuffle-in dup shuffle-in-d swap shuffle-in-r append ;

: shuffle-out dup shuffle-out-d swap shuffle-out-r append ;

TUPLE: shuffle-gadget value ;

: literal-theme ( shuffle -- )
    T{ solid f { 0.6 0.6 0.6 1.0 } } swap set-gadget-boundary ;

: word-theme ( shuffle -- )
    T{ solid f { 1.0 0.6 0.6 1.0 } } swap set-gadget-boundary ;

C: shuffle-gadget ( node -- gadget )
    [ set-shuffle-gadget-value ] keep
    dup delegate>gadget ;

: shuffled-offsets ( shuffle -- seq )
    dup shuffle-in swap shuffle-out [ swap index ] map-with ;

: shuffled-endpoints ( w seq seq -- seq )
    [ [ 30 * 15 + ] 2apply >r dupd 2array 0 r> 2array 2array ]
    2map nip ;

: draw-shuffle ( gadget seq seq -- )
    >r >r rect-dim first r> r> shuffled-endpoints
    [ first2 gl-line ] each ;

M: shuffle-gadget draw-gadget*
    { 0 0 0 1 } gl-color
    dup shuffle-gadget-value
    shuffled-offsets [ length ] keep
    draw-shuffle ;

: shuffle-dim ( shuffle -- node )
    dup shuffle-in length swap shuffle-out length max
    30 * 10 swap 2array ;

M: shuffle-gadget pref-dim*
    dup delegate pref-dim
    swap shuffle-gadget-value shuffle-dim
    vmax ;

TUPLE: height-gadget value skew ;

C: height-gadget ( value skew -- gadget )
    [ set-height-gadget-skew ] keep
    [ set-height-gadget-value ] keep
    dup delegate>gadget ;

M: height-gadget pref-dim*
    dup height-gadget-value swap height-gadget-skew abs +
    30 * 10 swap 2array ;

: height-offsets ( value skew -- seq seq )
    [ abs swap [ [ + ] map-with ] keep ] keep
    0 < [ swap ] when ;

M: height-gadget draw-gadget*
    { 0 0 0 1 } gl-color
    dup height-gadget-value over height-gadget-skew
    height-offsets draw-shuffle ;

TUPLE: node-gadget value ;

C: node-gadget ( gadget node -- gadget )
    [ set-node-gadget-value ] keep
    swap <default-border> over set-gadget-delegate ;

M: node-gadget pref-dim*
    dup delegate pref-dim
    swap node-gadget-value node-shuffle shuffle-dim
    vmax ;

GENERIC: node>gadget ( node -- gadget )

M: #call node>gadget
    [ node-param word-name <label> ] keep
    [ <node-gadget> ] keep node-param <object-presentation>
    dup word-theme ;

M: #push node>gadget
    [
        >#push< [ literalize unparse ] map " " join <label>
    ] keep <node-gadget> dup literal-theme ;

M: #shuffle node>gadget node-shuffle <shuffle-gadget> ;

DEFER: dataflow.

: <child-nodes> ( seq -- seq )
    [ length ] keep
    [
        >r number>string "Child " swap append <label> r>
        <object-presentation>
    ] 2map ;

M: object node>gadget
    [
        dup class word-name <label> ,
        dup node-children <child-nodes> %
    ] { } make make-pile
    { 5 5 } over set-pack-gap
    swap <node-gadget> dup faint-boundary ;

: (compute-heights) ( node -- )
    [
        [ node-d-height ] keep
        [ node-r-height ] keep
        [ 3array , ] keep
        node-successor (compute-heights)
    ] when* ;

: node-in-d# node-in-d length ;
: node-out-d# node-out-d length ;

: node-in-r# node-in-r length ;
: node-out-r# node-out-r length ;

: normalize-d-height ( seq -- seq )
    [ [ dup first swap third node-in-d# - ] map infimum ] keep
    [ first3 >r >r swap - r> r> 3array ] map-with ;

: normalize-r-height ( seq -- seq )
    [ [ dup second swap third node-in-r# - ] map infimum ] keep
    [ first3 >r rot - r> 3array ] map-with ;

: compute-heights ( nodes -- pairs )
    [ (compute-heights) ] { } make
    normalize-d-height normalize-r-height ;

: node-r-skew-1 ( node -- n )
    dup node-out-d# over node-in-r# [-] swap node-in-d# [-] ;

: node-r-skew-2 ( node -- n )
    dup node-in-d# over node-out-r# [-] swap node-out-d# [-] ;

SYMBOL: prev-node 

: node-r-skew ( node -- n )
    node-r-skew-1 prev-node get [ node-r-skew-2 - ] when* ;

: print-node ( d-height r-height node -- )
    [
        [
            pick 0 <height-gadget> ,
            2dup node-in-r# + over node-r-skew <height-gadget> ,
        ] { } make make-pile ,
        [
            rot over node-in-d# - 0 <height-gadget> ,
            node>gadget ,
            0 <height-gadget> ,
        ] { } make make-pile 1 over set-pack-fill ,
    ] keep prev-node set ;

: <dataflow-graph> ( node -- gadget )
    prev-node off
    compute-heights
    [ [ first3 print-node ] each ] { } make
    make-shelf ;

TUPLE: dataflow-gadget history search ;

dataflow-gadget {
    {
        "Dataflow"
        { "Back" T{ key-down f { C+ } "b" } [ dataflow-gadget-history go-back ] }
        { "Forward" T{ key-down f { C+ } "f" } [ dataflow-gadget-history go-forward ] }
    }
} define-commands

: <dataflow-pane> ( history -- gadget )
    gadget get dataflow-gadget-history
    [ <dataflow-graph> gadget. ]
    <pane-control> ;

C: dataflow-gadget ( -- gadget )
    f <history> over set-dataflow-gadget-history {
        { [ <dataflow-pane> ] f [ <scroller> ] @center }
    } make-frame* ;

M: dataflow-gadget call-tool* ( node dataflow -- )
    dup dataflow-gadget-history add-history
    dataflow-gadget-history set-model ;

IN: tools

: show-dataflow ( quot -- )
    dataflow optimize dataflow-gadget call-tool ;
