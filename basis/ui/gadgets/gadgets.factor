! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays binary-search combinators
concurrency.flags deques kernel make math math.order
math.rectangles math.vectors models namespaces sequences threads
vectors vocabs.loader ;
IN: ui.gadgets

! Values for orientation slot
CONSTANT: horizontal { 1 0 }
CONSTANT: vertical { 0 1 }

TUPLE: gadget < rect
    pref-dim
    parent
    children
    { orientation initial: { 0 1 } }
    focus
    { visible? initial: t }
    root?
    clipped?
    layout-state
    { graft-state initial: { f f } }
    graft-node
    interior
    boundary
    model ;

M: gadget equal? 2drop f ;

M: gadget hashcode* nip identity-hashcode ;

: gadget-child ( gadget -- child ) children>> first ; inline

: nth-gadget ( n gadget -- child ) children>> nth ; inline

: <gadget> ( -- gadget )
    gadget new ; inline

: control-value ( control -- value )
    model>> value>> ;

: set-control-value ( value control -- )
    model>> set-model ;

: relative-loc ( fromgadget togadget -- loc )
    2dup eq? [
        2drop { 0 0 }
    ] [
        [ [ parent>> ] dip relative-loc ] [ drop loc>> ] 2bi v+
    ] if ;

GENERIC: user-input* ( str gadget -- ? )

M: gadget user-input* 2drop t ;

GENERIC: temp-im-input ( str gadget -- ? )

M: gadget temp-im-input 2drop t ;

GENERIC: children-on ( rect gadget -- seq )

M: gadget children-on nip children>> ;

<PRIVATE

:: (fast-children-on) ( point axis children quot -- i )
    children [
        [ point ] dip
        quot call( value -- loc ) v-
        axis vdot 0 <=>
    ] search drop ; inline

PRIVATE>

:: fast-children-on ( rect axis children quot -- slice )
    rect loc>> axis children quot (fast-children-on) 0 or
    rect rect-bounds v+ axis children quot (fast-children-on) ?1+
    children <slice> ; inline

M: gadget contains-rect?
    dup visible?>> [ call-next-method ] [ 2drop f ] if ;

M: gadget contains-point?
    dup visible?>> [ call-next-method ] [ 2drop f ] if ;

: pick-up ( point gadget -- child/f )
    2dup [ dup point>rect ] dip children-on
    [ contains-point? ] with find-last nip
    or* [ [ loc>> v- ] [ pick-up ] bi ] [ nip ] if ;

: max-dims ( seq -- dim )
    [ 0 0 ] dip [ first2 swapd [ max ] 2bi@ ] each 2array ;

: sum-dims ( seq -- dim )
    [ 0 0 ] dip [ first2 swapd [ + ] 2bi@ ] each 2array ;

: each-child ( ... gadget quot: ( ... child -- ... ) -- ... )
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
    orientation>> vertical = "\n" "" ? ;

: gadget-seq-text ( seq gadget -- )
    gadget-text-separator '[ _ % ] [ gadget-text* ] interleave ;

M: gadget gadget-text*
    [ children>> ] keep gadget-seq-text ;

M: array gadget-text*
    [ gadget-text* ] each ;

: gadget-text ( gadget -- string ) [ gadget-text* ] "" make ;

DEFER: relayout

<PRIVATE

SYMBOL: ui-notify-flag

: notify-ui-thread ( -- ) ui-notify-flag get-global raise-flag ;

: invalidate ( gadget -- )
    \ invalidate >>layout-state drop ;

: forget-pref-dim ( gadget -- ) f >>pref-dim drop ;

: layout-queue ( -- queue )
    \ layout-queue get ;

CONSTANT: layout-queue-limit 8000

: layout-later ( gadget -- )
    layout-queue [
        [ push notify-ui-thread ]
        [ length layout-queue-limit > [ yield ] when ] bi
    ] [ drop ] if* ;

: invalidate* ( gadget -- )
    \ invalidate* >>layout-state
    dup forget-pref-dim
    dup root?>>
    [ layout-later ] [ parent>> [ relayout ] when* ] if ;

PRIVATE>

: relayout ( gadget -- )
    dup layout-state>> \ invalidate* eq?
    [ drop ] [ invalidate* ] if ;

: relayout-1 ( gadget -- )
    dup layout-state>>
    [ drop ] [ dup invalidate layout-later ] if ;

: show-gadget ( gadget -- ) t >>visible? drop ;

: hide-gadget ( gadget -- ) f >>visible? drop ;

<PRIVATE

SYMBOL: in-layout?

GENERIC: dim-changed ( gadget -- )

M: gadget dim-changed
    in-layout? get [ invalidate ] [ invalidate* ] if ;

PRIVATE>

M: gadget dim<<
    2dup dim>> =
    [ 2drop ]
    [ [ nip ] [ call-next-method ] 2bi dim-changed ] if ;

GENERIC: pref-dim* ( gadget -- dim )

: pref-dim ( gadget -- dim )
    [ pref-dim>> ] [
        [ pref-dim* ] [ ] [ layout-state>> ] tri
        [ drop ] [ dupd pref-dim<< ] if
    ] ?unless ;

: pref-dims ( gadgets -- seq ) [ pref-dim ] map ; inline

M: gadget pref-dim* dim>> ;

GENERIC: layout* ( gadget -- )

M: object layout* drop ;

: prefer ( gadget -- ) dup pref-dim >>dim drop ;

: layout ( gadget -- )
    dup layout-state>> [
        f >>layout-state
        dup layout*
        dup [ layout ] each-child
    ] when drop ;

GENERIC: graft* ( gadget -- )

M: object graft* drop ;

GENERIC: ungraft* ( gadget -- )

M: object ungraft* drop ;

<PRIVATE

: graft-queue ( -- dlist )
    \ graft-queue get [ "UI not running" throw ] unless* ;

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

: graft ( gadget -- )
    dup graft-later [ graft ] each-child ;

: ungraft-later ( gadget -- )
    dup graft-state>> {
        { { f f } [ drop ] }
        { { t f } [ drop ] }
        { { f t } [ unqueue-graft ] }
        { { t t } [ queue-ungraft ] }
    } case ;

: ungraft ( gadget -- )
    dup [ ungraft ] each-child ungraft-later ;

: activate-control ( gadget -- )
    dup model>> dup [
        2dup add-connection
        swap model-changed
    ] [
        2drop
    ] if ;

: deactivate-control ( gadget -- )
    dup model>> dup [ 2dup remove-connection ] when 2drop ;

: notify ( gadget -- )
    dup graft-state>>
    [ first { f f } { t t } ? >>graft-state ] [ ] bi
    {
        { { f t } [ dup activate-control graft* ] }
        { { t f } [ dup deactivate-control ungraft* ] }
    } case ;

: notify-queued ( -- )
    graft-queue [ notify ] slurp-deque ;

: (unparent) ( gadget -- )
    dup ungraft
    dup forget-pref-dim
    f >>parent drop ;

: (clear-gadget) ( gadget -- )
    dup [ (unparent) ] each-child
    f >>focus f >>children drop ;

: unfocus-gadget ( child gadget -- )
    [ nip ] [ focus>> eq? ] 2bi [ f >>focus ] when drop ;

PRIVATE>

: not-in-layout ( -- )
    in-layout? get
    [ "Cannot add/remove gadgets in layout*" throw ] when ;

GENERIC: remove-gadget ( gadget parent -- )

M: gadget remove-gadget 2drop ;

: unparent ( gadget -- )
    not-in-layout
    [
        dup parent>> [
            {
                [ remove-gadget ]
                [ drop (unparent) ]
                [ unfocus-gadget ]
                [ children>> remove! drop ]
                [ nip relayout ]
            } 2cleave
        ] [ drop ] if*
    ] when* ;

: clear-gadget ( gadget -- )
    not-in-layout
    [ (clear-gadget) ] [ relayout ] bi ;

<PRIVATE

: (add-gadget) ( child parent -- )
    {
        [ drop unparent ]
        [ >>parent drop ]
        [ [ ?push ] change-children drop ]
        [ graft-state>> second [ graft ] [ drop ] if ]
    } 2cleave ;

PRIVATE>

: add-gadget ( parent child -- parent )
    not-in-layout
    over (add-gadget)
    dup relayout ;

: add-gadgets ( parent children -- parent )
    not-in-layout
    over '[ _ (add-gadget) ] each
    dup relayout ;

: parents ( gadget -- seq )
    [ parent>> ] follow ;

: each-parent ( ... gadget quot: ( ... gadget -- ... ? ) -- ... ? )
    [ parents ] dip all? ; inline

: find-parent ( ... gadget quot: ( ... gadget -- ... ? ) -- ... parent )
    [ parents ] dip find nip ; inline

: screen-loc ( gadget -- loc )
    parents { 0 0 } [ loc>> v+ ] reduce ;

<PRIVATE

: (screen-rect) ( gadget -- loc ext )
    dup parent>> [
        [ rect-extent ] dip (screen-rect)
        [ [ nip ] [ v+ ] 2bi ] dip [ v+ ] [ vmin ] 2bi*
    ] [
        rect-extent
    ] if* ;

PRIVATE>

: screen-rect ( gadget -- rect )
    (screen-rect) <extent-rect> ;

: child? ( parent child -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup not ] [ 2drop f ] }
        [ parent>> child? ]
    } cond ;

GENERIC: focusable-child* ( gadget -- child/f )

M: object focusable-child* drop f ;

: focusable-child ( gadget -- child )
    dup focusable-child* [ nip focusable-child ] when* ;

GENERIC: request-focus-on ( child gadget -- )

M: gadget request-focus-on parent>> request-focus-on ;

M: f request-focus-on 2drop ;

: request-focus ( gadget -- )
    [ focusable-child ] keep request-focus-on ;

: focus-path ( gadget -- seq )
    [ focus>> ] follow ;

GENERIC: preedit? ( gadget -- ? )

M: gadget preedit? drop f ;

{ "ui.gadgets" "prettyprint" } "ui.gadgets.prettyprint" require-when
