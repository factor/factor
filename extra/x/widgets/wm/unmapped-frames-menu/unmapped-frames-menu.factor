
USING: kernel namespaces quotations arrays assocs sequences
       mortar slot-accessors x x.widgets.wm.menu x.widgets.wm.frame
       vars ;

IN: x.widgets.wm.unmapped-frames-menu

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: <unmapped-frames-menu>

<unmapped-frames-menu> <wm-menu> { } define-simple-class

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: unmapped-frames-menu

: create-unmapped-frames-menu ( -- )
<unmapped-frames-menu>
  new-empty
  <- keymenu-init
  1 <-- set-border-width
>unmapped-frames-menu ;

: unmapped-frames ( -- seq )
dpy get $window-table values
[ <wm-frame> is? ] subset [ <- mapped? not ] subset ;

<unmapped-frames-menu> {

"refresh" !( menu -- menu ) [
  unmapped-frames dup
  [ $child <- fetch-name ] map swap
  [ [ <- map ] curry ] map
  [ 2array ] 2map
  >>items
  dup <- calc-size <-- resize ]

"popup" !( menu -- menu ) [ <- refresh <- wm-menu-popup ]

} add-methods