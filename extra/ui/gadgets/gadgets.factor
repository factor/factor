! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables kernel models math namespaces sequences
timers quotations math.vectors combinators sorting vectors
dlists models ;
IN: ui.gadgets

TUPLE: rect loc dim ;

C: <rect> rect

M: array rect-loc ;

M: array rect-dim drop { 0 0 } ;

: rect-bounds ( rect -- loc dim ) dup rect-loc swap rect-dim ;

: rect-extent ( rect -- loc ext ) rect-bounds over v+ ;

: 2rect-extent ( rect rect -- loc1 loc2 ext1 ext2 )
    [ rect-extent ] 2apply swapd ;

: <extent-rect> ( loc ext -- rect ) over [v-] <rect> ;

: offset-rect ( rect loc -- newrect )
    over rect-loc v+ swap rect-dim <rect> ;

: (rect-intersect) ( rect rect -- array array )
    2rect-extent vmin >r vmax r> ;

: rect-intersect ( rect1 rect2 -- newrect )
    (rect-intersect) <extent-rect> ;

: intersects? ( rect/point rect -- ? )
    (rect-intersect) [v-] { 0 0 } = ;

: (rect-union) ( rect rect -- array array )
    2rect-extent vmax >r vmin r> ;

: rect-union ( rect1 rect2 -- newrect )
    (rect-union) <extent-rect> ;

TUPLE: gadget
pref-dim parent children orientation focus
visible? root? clipped? layout-state graft-state
interior boundary
model ;

M: gadget equal? 2drop f ;

M: gadget hashcode* drop gadget hashcode* ;

M: gadget model-changed drop ;

: gadget-child ( gadget -- child ) gadget-children first ;

: nth-gadget ( n gadget -- child ) gadget-children nth ;

: <zero-rect> ( -- rect ) { 0 0 } dup <rect> ;

: <gadget> ( -- gadget )
    <zero-rect> { 0 1 } t { f f } {
        set-delegate
        set-gadget-orientation
        set-gadget-visible?
        set-gadget-graft-state
    } gadget construct ;

: construct-gadget ( class -- tuple )
    >r <gadget> r> construct-delegate ; inline

: activate-control ( gadget -- )
    dup gadget-model dup [ 2dup add-connection ] when drop
    model-changed ;

: deactivate-control ( gadget -- )
    dup gadget-model dup [ 2dup remove-connection ] when 2drop ;

: control-value ( control -- value )
    gadget-model model-value ;

: set-control-value ( value control -- )
    gadget-model set-model ;

: relative-loc ( fromgadget togadget -- loc )
    2dup eq? [
        2drop { 0 0 }
    ] [
        over rect-loc >r
        >r gadget-parent r> relative-loc
        r> v+
    ] if ;

GENERIC: user-input* ( str gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: children-on ( rect/point gadget -- seq )

M: gadget children-on nip gadget-children ;

: (fast-children-on) ( dim axis gadgets -- i )
    swapd [ rect-loc v- over v. ] binsearch nip ;

: fast-children-on ( rect axis children -- from to )
    3dup
    >r >r dup rect-loc swap rect-dim v+
    r> r> (fast-children-on) [ 1+ ] [ 0 ] if*
    >r
    >r >r rect-loc
    r> r> (fast-children-on) 0 or
    r> ;

: inside? ( bounds gadget -- ? )
    dup gadget-visible? [ intersects? ] [ 2drop f ] if ;

: (pick-up) ( point gadget -- gadget )
    dupd children-on [ inside? ] curry* find-last nip ;

: pick-up ( point gadget -- child/f )
    2dup (pick-up) dup
    [ nip [ rect-loc v- ] keep pick-up ] [ rot 2drop ] if ;

: max-dim ( dims -- dim ) { 0 0 } [ vmax ] reduce ;

: dim-sum ( seq -- dim ) { 0 0 } [ v+ ] reduce ;

: orient ( gadget seq1 seq2 -- seq )
    >r >r gadget-orientation r> r> [ pick set-axis ] 2map nip ;

: each-child ( gadget quot -- )
    >r gadget-children r> each ; inline

: set-gadget-delegate ( gadget tuple -- )
    over [
        dup pick [ set-gadget-parent ] curry* each-child
    ] when set-delegate ;

: construct-control ( model gadget class -- control )
    >r tuck set-gadget-model
    { set-gadget-delegate } r> construct ; inline

! Selection protocol
GENERIC: gadget-selection? ( gadget -- ? )

M: gadget gadget-selection? drop f ;

GENERIC: gadget-selection ( gadget -- string/f )

M: gadget gadget-selection drop f ;

! Text protocol
GENERIC: gadget-text* ( gadget -- )

GENERIC: gadget-text-separator ( gadget -- str )

M: gadget gadget-text-separator
    gadget-orientation { 0 1 } = "\n" "" ? ;

: gadget-seq-text ( seq gadget -- )
    gadget-text-separator swap
    [ dup % ] [ gadget-text* ] interleave drop ;

M: gadget gadget-text*
    dup gadget-children swap gadget-seq-text ;

M: array gadget-text*
    [ gadget-text* ] each ;

: gadget-text ( gadget -- string ) [ gadget-text* ] "" make ;

: invalidate ( gadget -- )
    \ invalidate swap set-gadget-layout-state ;

: forget-pref-dim ( gadget -- ) f swap set-gadget-pref-dim ;

: layout-queue ( -- queue ) \ layout-queue get ;

: layout-later ( gadget -- )
    #! When unit testing gadgets without the UI running, the
    #! invalid queue is not initialized and we simply ignore
    #! invalidation requests.
    layout-queue [ push-front ] [ drop ] if* ;

DEFER: relayout

: invalidate* ( gadget -- )
    \ invalidate* over set-gadget-layout-state
    dup forget-pref-dim
    dup gadget-root?
    [ layout-later ] [ gadget-parent [ relayout ] when* ] if ;

: relayout ( gadget -- )
    dup gadget-layout-state \ invalidate* eq?
    [ drop ] [ invalidate* ] if ;

: relayout-1 ( gadget -- )
    dup gadget-layout-state
    [ drop ] [ dup invalidate layout-later ] if ;

: show-gadget t swap set-gadget-visible? ;

: hide-gadget f swap set-gadget-visible? ;

: (set-rect-dim) ( dim gadget quot -- )
    >r 2dup rect-dim =
    [ [ 2drop ] [ set-rect-dim ] if ] 2keep
    [ drop ] r> if ; inline

: set-layout-dim ( dim gadget -- )
    [ invalidate ] (set-rect-dim) ;

: set-gadget-dim ( dim gadget -- )
    [ invalidate* ] (set-rect-dim) ;

GENERIC: pref-dim* ( gadget -- dim )

: ?set-gadget-pref-dim ( dim gadget -- )
    dup gadget-layout-state
    [ 2drop ] [ set-gadget-pref-dim ] if ;

: pref-dim ( gadget -- dim )
    dup gadget-pref-dim [ ] [
        [ pref-dim* dup ] keep ?set-gadget-pref-dim
    ] ?if ;

: pref-dims ( gadgets -- seq ) [ pref-dim ] map ;

M: gadget pref-dim* rect-dim ;

GENERIC: layout* ( gadget -- )

M: gadget layout* drop ;

: prefer ( gadget -- ) dup pref-dim swap set-layout-dim ;

: validate ( gadget -- ) f swap set-gadget-layout-state ;

: layout ( gadget -- )
    dup gadget-layout-state [
        dup validate
        dup layout*
        dup [ layout ] each-child
    ] when drop ;

: graft-queue \ graft-queue get ;

: unqueue-graft ( gadget -- )
    dup graft-queue dlist-delete [ "Not queued" throw ] unless
    dup gadget-graft-state first { t t } { f f } ?
    swap set-gadget-graft-state ;

: queue-graft ( gadget -- )
    { f t } over set-gadget-graft-state
    graft-queue push-front ;

: queue-ungraft ( gadget -- )
    { t f } over set-gadget-graft-state
    graft-queue push-front ;

: graft-later ( gadget -- )
    dup gadget-graft-state {
        { { f t } [ drop ] }
        { { t t } [ drop ] }
        { { t f } [ unqueue-graft ] }
        { { f f } [ queue-graft ] }
    } case ;

: ungraft-later ( gadget -- )
    dup gadget-graft-state {
        { { f f } [ drop ] }
        { { t f } [ drop ] }
        { { f t } [ unqueue-graft ] }
        { { t t } [ queue-ungraft ] }
    } case ;

GENERIC: graft* ( gadget -- )

M: gadget graft* drop ;

: graft ( gadget -- )
    dup graft-later [ graft ] each-child ;

GENERIC: ungraft* ( gadget -- )

M: gadget ungraft* drop ;

: ungraft ( gadget -- )
    dup [ ungraft ] each-child ungraft-later ;

: (unparent) ( gadget -- )
    dup ungraft
    dup forget-pref-dim
    f swap set-gadget-parent ;

: unfocus-gadget ( child gadget -- )
    tuck gadget-focus eq?
    [ f swap set-gadget-focus ] [ drop ] if ;

SYMBOL: in-layout?

: not-in-layout
    in-layout? get
    [ "Cannot add/remove gadgets in layout*" throw ] when ;

: unparent ( gadget -- )
    not-in-layout
    [
        dup gadget-parent dup [
            over (unparent)
            [ unfocus-gadget ] 2keep
            [ gadget-children delete ] keep
            relayout
        ] [
            2drop
        ] if
    ] when* ;

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child
    f over set-gadget-focus
    f swap set-gadget-children ;

: clear-gadget ( gadget -- )
    not-in-layout
    dup (clear-gadget) relayout ;

: ((add-gadget)) ( gadget box -- )
    [ gadget-children ?push ] keep set-gadget-children ;

: (add-gadget) ( gadget box -- )
    over unparent
    dup pick set-gadget-parent
    [ ((add-gadget)) ] 2keep
    gadget-graft-state second [ graft ] [ drop ] if ;

: add-gadget ( gadget parent -- )
    not-in-layout
    [ (add-gadget) ] keep relayout ;

: add-gadgets ( seq parent -- )
    not-in-layout
    swap [ over (add-gadget) ] each relayout ;

: parents ( gadget -- seq )
    [ dup ] [ [ gadget-parent ] keep ] [ ] unfold nip ;

: each-parent ( gadget quot -- ? )
    >r parents r> all? ; inline

: find-parent ( gadget quot -- parent )
    >r parents r> find nip ; inline

: screen-loc ( gadget -- loc )
    parents { 0 0 } [ rect-loc v+ ] reduce ;

: (screen-rect) ( gadget -- loc ext )
    dup gadget-parent [
        >r rect-extent r> (screen-rect)
        >r tuck v+ r> vmin >r v+ r>
    ] [
        rect-extent
    ] if* ;

: screen-rect ( gadget -- rect )
    (screen-rect) <extent-rect> ;

: child? ( parent child -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup not ] [ 2drop f ] }
        { [ t ] [ gadget-parent child? ] }
    } cond ;

GENERIC: focusable-child* ( gadget -- child/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- child )
    dup focusable-child*
    dup t eq? [ drop ] [ nip focusable-child ] if ;

GENERIC: request-focus-on ( child gadget -- )

M: gadget request-focus-on gadget-parent request-focus-on ;

M: f request-focus-on 2drop ;

: request-focus ( gadget -- )
    dup focusable-child swap request-focus-on ;

: focus-path ( world -- seq )
    [ dup ] [ [ gadget-focus ] keep ] [ ] unfold nip ;

: make-gadget ( quot gadget -- gadget )
    [ \ make-gadget rot with-variable ] keep ; inline

: gadget, ( gadget -- ) \ make-gadget get add-gadget ;

: g ( -- gadget ) gadget get ;

: g-> ( x -- x x gadget ) dup g ;

: with-gadget ( gadget quot -- )
    [
        swap dup \ make-gadget set gadget set call
    ] with-scope ; inline

: build-gadget ( tuple quot gadget -- tuple )
    pick set-gadget-delegate over >r with-gadget r> ; inline
