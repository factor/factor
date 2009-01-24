! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables kernel models math namespaces
make sequences quotations math.vectors combinators sorting
binary-search vectors dlists deques models threads
concurrency.flags math.order math.geometry.rect fry ;
IN: ui.gadgets

SYMBOL: ui-notify-flag

: notify-ui-thread ( -- ) ui-notify-flag get-global raise-flag ;

TUPLE: gadget < rect pref-dim parent children orientation focus
visible? root? clipped? layout-state graft-state graft-node
interior boundary model ;

M: gadget equal? 2drop f ;

M: gadget hashcode* drop gadget hashcode* ;

M: gadget model-changed 2drop ;

: gadget-child ( gadget -- child ) children>> first ;

: nth-gadget ( n gadget -- child ) children>> nth ;

: init-gadget ( gadget -- gadget )
    init-rect
    { 0 1 } >>orientation
    t >>visible?
    { f f } >>graft-state ; inline

: new-gadget ( class -- gadget ) new init-gadget ; inline

: <gadget> ( -- gadget )
    gadget new-gadget ;

: activate-control ( gadget -- )
    dup model>> dup [
        2dup add-connection
        swap model-changed
    ] [
        2drop
    ] if ;

: deactivate-control ( gadget -- )
    dup model>> dup [ 2dup remove-connection ] when 2drop ;

: control-value ( control -- value )
    model>> value>> ;

: set-control-value ( value control -- )
    model>> set-model ;

: relative-loc ( fromgadget togadget -- loc )
    2dup eq? [
        2drop { 0 0 }
    ] [
        over rect-loc [ [ parent>> ] dip relative-loc ] dip v+
    ] if ;

GENERIC: user-input* ( str gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: children-on ( rect/point gadget -- seq )

M: gadget children-on nip children>> ;

: ((fast-children-on)) ( gadget dim axis -- <=> )
    [ swap loc>> v- ] dip v. 0 <=> ;

: (fast-children-on) ( dim axis children -- i )
    -rot '[ _ _ ((fast-children-on)) ] search drop ;

: fast-children-on ( rect axis children -- from to )
    [ [ rect-loc ] 2dip (fast-children-on) 0 or ]
    [ [ rect-bounds v+ ] 2dip (fast-children-on) ?1+ ]
    3bi ;

: inside? ( bounds gadget -- ? )
    dup visible?>> [ intersects? ] [ 2drop f ] if ;

: (pick-up) ( point gadget -- gadget )
    dupd children-on [ inside? ] with find-last nip ;

: pick-up ( point gadget -- child/f )
    2dup (pick-up) dup
    [ nip [ rect-loc v- ] keep pick-up ] [ drop nip ] if ;

: max-dim ( dims -- dim ) { 0 0 } [ vmax ] reduce ;

: dim-sum ( seq -- dim ) { 0 0 } [ v+ ] reduce ;

: each-child ( gadget quot -- )
    [ children>> ] dip each ; inline

! Selection protocol
GENERIC: gadget-selection? ( gadget -- ? )

M: gadget gadget-selection? drop f ;

GENERIC: gadget-selection ( gadget -- string/f )

M: gadget gadget-selection drop f ;

! Text protocol
GENERIC: gadget-text* ( gadget -- )

GENERIC: gadget-text-separator ( gadget -- str )

M: gadget gadget-text-separator
    orientation>> { 0 1 } = "\n" "" ? ;

: gadget-seq-text ( seq gadget -- )
    gadget-text-separator swap
    [ dup % ] [ gadget-text* ] interleave drop ;

M: gadget gadget-text*
    dup children>> swap gadget-seq-text ;

M: array gadget-text*
    [ gadget-text* ] each ;

: gadget-text ( gadget -- string ) [ gadget-text* ] "" make ;

: invalidate ( gadget -- )
    \ invalidate >>layout-state drop ;

: forget-pref-dim ( gadget -- ) f >>pref-dim drop ;

: layout-queue ( -- queue ) \ layout-queue get ;

: layout-later ( gadget -- )
    #! When unit testing gadgets without the UI running, the
    #! invalid queue is not initialized and we simply ignore
    #! invalidation requests.
    layout-queue [ push-front notify-ui-thread ] [ drop ] if* ;

DEFER: relayout

: invalidate* ( gadget -- )
    \ invalidate* >>layout-state
    dup forget-pref-dim
    dup root?>>
    [ layout-later ] [ parent>> [ relayout ] when* ] if ;

: relayout ( gadget -- )
    dup layout-state>> \ invalidate* eq?
    [ drop ] [ invalidate* ] if ;

: relayout-1 ( gadget -- )
    dup layout-state>>
    [ drop ] [ dup invalidate layout-later ] if ;

: show-gadget ( gadget -- ) t >>visible? drop ;
                              
: hide-gadget ( gadget -- ) f >>visible? drop ;

DEFER: in-layout?

GENERIC: dim-changed ( gadget -- )

M: gadget dim-changed
    in-layout? get [ invalidate ] [ invalidate* ] if ;

M: gadget (>>dim) ( dim gadget -- )
    2dup dim>> =
    [ 2drop ]
    [ [ nip ] [ call-next-method ] 2bi dim-changed ] if ;

GENERIC: pref-dim* ( gadget -- dim )

: ?set-gadget-pref-dim ( dim gadget -- )
    dup layout-state>>
    [ 2drop ] [ (>>pref-dim) ] if ;

: pref-dim ( gadget -- dim )
    dup pref-dim>> [ ] [
        [ pref-dim* dup ] keep ?set-gadget-pref-dim
    ] ?if ;

: pref-dims ( gadgets -- seq ) [ pref-dim ] map ;

M: gadget pref-dim* rect-dim ;

GENERIC: layout* ( gadget -- )

M: gadget layout* drop ;

: prefer ( gadget -- ) dup pref-dim >>dim drop ;

: validate ( gadget -- ) f >>layout-state drop ;

: layout ( gadget -- )
    dup layout-state>> [
        dup validate
        dup layout*
        dup [ layout ] each-child
    ] when drop ;

: graft-queue ( -- dlist ) \ graft-queue get ;

: unqueue-graft ( gadget -- )
    [ graft-node>> graft-queue delete-node ]
    [ [ first { t t } { f f } ? ] change-graft-state drop ] bi ;

: (queue-graft) ( gadget flags -- )
    >>graft-state
    dup graft-queue push-front* >>graft-node drop
    notify-ui-thread ;

: queue-graft ( gadget -- )
    { f t } (queue-graft) ;

: queue-ungraft ( gadget -- )
    { t f } (queue-graft) ;

: graft-later ( gadget -- )
    dup graft-state>> {
        { { f t } [ drop ] }
        { { t t } [ drop ] }
        { { t f } [ unqueue-graft ] }
        { { f f } [ queue-graft ] }
    } case ;

: ungraft-later ( gadget -- )
    dup graft-state>> {
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
    f >>parent drop ;

: unfocus-gadget ( child gadget -- )
    [ nip ] [ focus>> eq? ] 2bi [ f >>focus ] when drop ;

SYMBOL: in-layout?

: not-in-layout ( -- )
    in-layout? get
    [ "Cannot add/remove gadgets in layout*" throw ] when ;

: unparent ( gadget -- )
    not-in-layout
    [
        dup parent>> dup [
            over (unparent)
            [ unfocus-gadget ] 2keep
            [ children>> delete ] keep
            relayout
        ] [
            2drop
        ] if
    ] when* ;

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child
    f >>focus f >>children drop ;

: clear-gadget ( gadget -- )
    not-in-layout
    dup (clear-gadget) relayout ;

: ((add-gadget)) ( parent child -- parent )
    over children>> ?push >>children ;

: (add-gadget) ( parent child -- parent )
    dup unparent
    over >>parent
    tuck ((add-gadget))
    tuck graft-state>> second [ graft ] [ drop  ] if ;

: add-gadget ( parent child -- parent )
    not-in-layout
    (add-gadget)
    dup relayout ;

: add-gadgets ( parent children -- parent )
    not-in-layout
    [ (add-gadget) ] each
    dup relayout ;

: parents ( gadget -- seq )
    [ parent>> ] follow ;

: each-parent ( gadget quot -- ? )
    [ parents ] dip all? ; inline

: find-parent ( gadget quot -- parent )
    [ parents ] dip find nip ; inline

: screen-loc ( gadget -- loc )
    parents { 0 0 } [ rect-loc v+ ] reduce ;

: (screen-rect) ( gadget -- loc ext )
    dup parent>> [
        [ rect-extent ] dip (screen-rect)
        [ [ nip ] [ v+ ] 2bi ] dip [ vmin ] [ v+ ] 2bi*
    ] [
        rect-extent
    ] if* ;

: screen-rect ( gadget -- rect )
    (screen-rect) <extent-rect> ;

: child? ( parent child -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup not ] [ 2drop f ] }
        [ parent>> child? ]
    } cond ;

GENERIC: focusable-child* ( gadget -- child/t )

M: gadget focusable-child* drop t ;

: focusable-child ( gadget -- child )
    dup focusable-child*
    dup t eq? [ drop ] [ nip focusable-child ] if ;

GENERIC: request-focus-on ( child gadget -- )

M: gadget request-focus-on parent>> request-focus-on ;

M: f request-focus-on 2drop ;

: request-focus ( gadget -- )
    [ focusable-child ] keep request-focus-on ;

: focus-path ( world -- seq )
    [ focus>> ] follow ;
