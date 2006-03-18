! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: errors gadgets generic hashtables kernel lists math
namespaces queues sequences ;
IN: gadgets-layouts

: invalidate ( gadget -- ) t swap set-gadget-relayout? ;

: forget-pref-dim ( gadget -- ) f swap set-gadget-pref-dim ;

: invalidate* ( gadget -- ) dup invalidate forget-pref-dim ;

: invalid ( -- queue ) \ invalid global hash ;

<queue> \ invalid set-global

: add-invalid ( gadget -- ) invalid enque ;

: relayout ( gadget -- )
    #! Relayout and redraw a gadget and its parent before the
    #! next iteration of the event loop. Should be used when the
    #! gadget's size has potentially changed. See relayout-1.
    dup gadget-relayout? [
        drop
    ] [
        dup invalidate*
        dup gadget-root?
        [ add-invalid ] [ gadget-parent [ relayout ] when* ] if
    ] if ;

: relayout-1 ( gadget -- )
    #! Relayout and redraw a gadget before th next iteration of
    #! the event loop. Should be used if the gadget should be
    #! repainted, or if its internal layout changed, but its
    #! preferred size did not change.
    dup gadget-relayout?
    [ drop ] [ dup invalidate add-invalid ] if ;

: toggle-visible ( gadget -- )
    dup gadget-visible? not over set-gadget-visible? relayout-1 ;

: set-gadget-dim ( dim gadget -- )
    2dup rect-dim = [
        2drop
    ] [
        [ set-rect-dim ] keep dup add-invalid invalidate
    ] if ;

GENERIC: pref-dim* ( gadget -- dim )

: pref-dim ( gadget -- dim )
    dup gadget-pref-dim [ ] [
        dup pref-dim* dup rot set-gadget-pref-dim
    ] ?if ;

M: gadget pref-dim* rect-dim ;

GENERIC: layout* ( gadget -- )

M: gadget layout* drop ;

: prefer ( gadget -- ) dup pref-dim swap set-gadget-dim ;

DEFER: layout

: layout-children ( gadget -- ) [ layout ] each-child ;

: layout ( gadget -- )
    #! Position the children of the gadget inside the gadget.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        f over set-gadget-relayout?
        dup layout* dup layout-children
    ] when drop ;

: layout-queued ( -- )
    invalid dup queue-empty?
    [ drop ] [ deque dup layout layout-done layout-queued ] if ;

TUPLE: pack align fill gap ;

: pref-dims ( gadget -- list ) [ pref-dim ] map ;

: orient ( gadget seq1 seq2 -- seq )
    >r >r gadget-orientation r> r> [ pick set-axis ] 2map nip ;

: packed-dim-2 ( gadget sizes -- list )
    [ over rect-dim over v- rot pack-fill v*n v+ ] map-with ;

: packed-dims ( gadget sizes -- seq )
    2dup packed-dim-2 swap orient ;

: packed-loc-1 ( gadget sizes -- seq )
    { 0 0 0 } [ v+ over pack-gap v+ ] accumulate nip ;

: packed-loc-2 ( gadget sizes -- seq )
    [
        >r dup pack-align swap rect-dim r> v- n*v
        [ >fixnum ] map
    ] map-with ;

: packed-locs ( gadget sizes -- seq )
    2dup packed-loc-1 >r dupd packed-loc-2 r> orient ;

: packed-layout ( gadget sizes -- )
    over gadget-children
    >r dupd packed-dims r> 2dup [ set-gadget-dim ] 2each
    >r packed-locs r> [ set-rect-loc ] 2each ;

C: pack ( vector -- pack )
    #! gap: between each child.
    #! fill: 0 leaves default width, 1 fills to pack width.
    #! align: 0 left, 1/2 center, 1 right.
    dup delegate>gadget
    [ set-gadget-orientation ] keep
    0 over set-pack-align
    0 over set-pack-fill
    { 0 0 0 } over set-pack-gap ;

: delegate>pack ( vector tuple -- ) >r <pack> r> set-delegate ;

: <pile> ( -- pack ) { 0 1 0 } <pack> ;

: <shelf> ( -- pack ) { 1 0 0 } <pack> ;

: pack-pref-dim ( children gadget -- dim )
    [
        >r [ max-dim ] keep
        [ { 0 0 0 } [ v+ ] reduce ] keep length 1 - 0 max
        r> pack-gap n*v v+
    ] keep gadget-orientation set-axis ;

M: pack pref-dim* ( pack -- dim )
    [ gadget-children pref-dims ] keep pack-pref-dim ;

M: pack layout* ( pack -- )
    dup gadget-children pref-dims packed-layout ;

: fast-children-on ( dim axis gadgets -- i )
    swapd [ rect-loc origin get v+ v- over v. ] binsearch nip ;

M: pack children-on ( rect pack -- list )
    dup gadget-orientation swap gadget-children [
        3dup
        >r >r dup rect-loc swap rect-dim v+ r> r> fast-children-on 1+
        >r
        >r >r rect-loc r> r> fast-children-on 0 max
        r>
    ] keep <slice> ;

TUPLE: stack ;

C: stack ( -- gadget )
    #! A stack lays out all its children on top of each other.
    { 0 0 1 } over delegate>pack 1 over set-pack-fill ;

M: stack children-on ( point stack -- gadget )
    nip gadget-children ;
