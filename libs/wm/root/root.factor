
USING: kernel generic x11 x.geometry x x.widgets wm.frame ;

IN: wm.root

TUPLE: wm-root key-action ;

: wm-root-mask ( -- mask )
{
  SubstructureRedirectMask
} ;

C: wm-root ( -- wm-root )
root over set-delegate dup add-to-window-table wm-root-mask over select-input ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Event handlers
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: hashtables sequences x wm.child ;

: managed? ( id -- ? )
window-table> hash-values [ child? ] subset [ window-id ] map member? ;

! The USING: sequences above is needed to get subset. However, it
! shadows the x.geometry move so we get it back here:

USE: x.geometry

USING: io ;

M: wm-root handle-map-request ( event wm-root -- )
{ { [ over XMapRequestEvent-window managed? ]
    [ "wm-root handle-map-request :: window already managed" print flush
      2drop ] }
  { [ t ] [ drop XMapRequestEvent-window id>window <frame> ] }
} cond ;

M: wm-root handle-unmap ( event wm-root -- ) 2drop ;

M: wm-root handle-key-press ( event wm-root -- ) dup wm-root-key-action call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: io namespaces math arrays vars wm.root ;

: bit-test ( a b -- t-or-f ) bitand 0 = not ;

VARS: event win ;

: value-mask event> XConfigureRequestEvent-value_mask ;

: event-x event> XConfigureRequestEvent-x ;
: event-y event> XConfigureRequestEvent-y ;

: event-width  event> XConfigureRequestEvent-width ;
: event-height event> XConfigureRequestEvent-height ;

M: wm-root handle-configure-request ( event wm-root -- ) [
drop dup XConfigureRequestEvent-window id>window >win
>event

{ { [ value-mask CWX bit-test   value-mask CWY bit-test   and ]
    [ event-x event-y 2array win> move ] }
  { [ value-mask CWX bit-test ] [ event-x win> set-x ] }
  { [ value-mask CWY bit-test ] [ event-y win> set-y ] }
  { [ t ]
    [ "wm-root handle-configure-request :: move not requested" print flush ] }
} cond

{ { [ value-mask CWWidth bit-test   value-mask CWHeight bit-test   and ]
    [ event-width event-height 2array win> resize ] }
  { [ value-mask CWWidth bit-test ] [ event-width win> set-width ] }
  { [ value-mask CWHeight bit-test ] [ event-height win> set-height ] }
  { [ t ]
    [ "wm-root handle-configure-request :: resize not requested"
      print flush ] }
} cond

] with-scope ;