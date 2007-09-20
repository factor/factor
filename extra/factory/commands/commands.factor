
USING: kernel combinators sequences math math.vectors mortar slot-accessors
       x x.widgets.wm.root x.widgets.wm.frame combinators.lib ;

IN: factory.commands

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: up-till-frame ( window -- wm-frame )
{ { [ dup <wm-frame> is? ]
    [ ] }
  { [ dup $dpy $default-root $id over $id = ]
    [ drop f ] }
  { [ t ]
    [ <- parent up-till-frame ] } } cond ;

: pointer-window ( -- window ) dpy> <- pointer-window ;

: pointer-frame ( -- wm-frame )
pointer-window up-till-frame dup <wm-frame> is? [ ] [ drop f ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: maximize ( -- ) pointer-frame wm-frame-maximize drop ;

: minimize ( -- ) pointer-frame <- unmap drop ;

: maximize-vertical ( -- ) pointer-frame wm-frame-maximize-vertical drop ;

: restore ( -- ) pointer-frame <- restore-state drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



: tile-master ( -- )

wm-root>
  <- children
  [ <- mapped? ] subset
  [ check-window-table ] map
  reverse

unclip
  { 0 0 } <-- move
  wm-root> <- size { 1/2 1 } v*
  [ floor ] map <-- resize
  <- adjust-child
drop

dup empty? [ drop ] [

wm-root> <- width 2 / floor [ <-- set-width ] curry map
wm-root> <- height over length / floor [ <-- set-height ] curry map

wm-root> <- width 2 / floor [ <-- set-x ] curry map

wm-root> <- height over length /   over length   [ * floor ] map-with
[ <-- set-y <- adjust-child ] 2map

drop

] if ;

! : tile-master ( -- )

! wm-root>
!   <- children
!   [ <- mapped? ] subset
!   [ check-window-table ] map
!   reverse

! { { [ dup empty? ] [ drop ] }
!   { [ dup length 1 = ] [ drop maximize ] }
!   { [ t ] [ tile-master* ] }