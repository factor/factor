! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-mindmap
USING: gadgets gadgets-buttons gadgets-labels gadgets-layouts
generic kernel math sequences styles ;

! Mind-map tree-view gadget, like http://freemind.sf.net.

! Mind-map node protocol
GENERIC: node-gadget ( node -- gadget )
GENERIC: node-left ( node -- seq )
GENERIC: node-right ( node -- seq )

TUPLE: mindmap left node gadget right expanded? left? right? ;

: add-mindmap-node ( mindmap -- )
    dup mindmap-node node-gadget swap
    2dup add-gadget set-mindmap-gadget ;

: collapse-mindmap ( mindmap -- )
    f over set-mindmap-expanded?
    f over set-mindmap-left
    f over set-mindmap-right
    dup clear-gadget
    add-mindmap-node ;

: mindmap-child ( left? right? obj -- gadget )
    dup [ gadget? ] is? [ 2nip ] [ <mindmap> ] ifte ;

: mindmap-children ( seq left? right? -- gadget )
    rot [ >r 2dup r> mindmap-child ] map 2nip
    <pile> @{ 0 5 0 }@ over set-pack-gap [ add-gadgets ] keep ;

: (expand-left) ( node -- gadget )
    mindmap-node node-left t f mindmap-children
    1 over set-pack-align ;

: (expand-right) ( node -- gadget )
    mindmap-node node-right f t mindmap-children
    0 over set-pack-align ;

: add-nonempty ( child gadget -- )
    over gadget-children empty? [ 2drop ] [ add-gadget ] ifte ;

: if-left ( mindmap quot -- | quot: mindmap -- )
    >r dup mindmap-left? r> [ drop ] ifte ; inline

: expand-left ( mindmap -- )
    [
        dup (expand-left) swap 2dup
        add-nonempty set-mindmap-left
    ] if-left ;

: if-right ( mindmap quot -- | quot: mindmap -- )
    >r dup mindmap-right? r> [ drop ] ifte ; inline

: expand-right ( mindmap -- )
    [
        dup (expand-right) swap 2dup
        add-nonempty set-mindmap-right
    ] if-right ;

: expand-mindmap ( mindmap -- )
    t over set-mindmap-expanded?
    dup clear-gadget
    dup expand-left
    dup add-mindmap-node
    expand-right ;

: toggle-expanded ( mindmap -- )
    dup mindmap-expanded?
    [ collapse-mindmap ] [ expand-mindmap ] ifte ;

C: mindmap ( left? right? node -- gadget )
    <shelf> over set-delegate
    1/2 over set-pack-align
    @{ 50 0 0 }@ over set-pack-gap
    [ set-mindmap-node ] keep
    [ set-mindmap-right? ] keep
    [ set-mindmap-left? ] keep
    dup collapse-mindmap ;

: draw-arrows ( mindmap child point -- )
    tuck >r >r >r mindmap-gadget r> @{ 1 1 1 }@ swap v-
    gadget-point r> gadget-children r> swap
    [ swap gadget-point ] map-with gray draw-fanout ;

: draw-left-arrows ( mindmap -- )
    [ dup mindmap-left { 1 1/2 1/2 } draw-arrows ] if-left ;

: draw-right-arrows ( mindmap -- )
    [ dup mindmap-right { 0 1/2 1/2 } draw-arrows ] if-right ;

M: mindmap draw-gadget* ( mindmap -- )
    dup delegate draw-gadget*
    dup mindmap-expanded? [
        dup draw-left-arrows dup draw-right-arrows
    ] when drop ;

: find-mindmap [ mindmap? ] find-parent ;

: <expand-button> ( label -- gadget )
    <label> [ find-mindmap toggle-expanded ] <roll-button> ;
