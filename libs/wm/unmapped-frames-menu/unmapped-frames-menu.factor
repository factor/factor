
USING: kernel namespaces generic sequences arrays hashtables x11
       vars x.geometry x x.widgets x.widgets.keymenu wm.frame wm.menu ;

IN: wm.unmapped-frames-menu

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: unmapped-frames-menu ;

C: unmapped-frames-menu ( -- menu )
{ } clone <wm-menu>
over set-delegate
dup add-to-window-table
{ ExposureMask KeyPressMask } over select-input ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unmapped-frames ( -- seq )
window-table> hash-values [ frame? ] subset [ mapped? not ] subset ;

: frame-name ( frame -- name ) frame-child fetch-name ;

VARS: menu frames ;

: refresh-unmapped-frames-menu ( menu -- ) [ >menu unmapped-frames >frames
frames> [ frame-name ] map
frames> [ [ map-window ] curry ] map
[ 2array ] 2map
menu> set-keymenu-items
menu> calc-size menu> resize
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: unmapped-frames-menu popup ( menu -- )
dup refresh-unmapped-frames-menu
dup raise
dup map-window   RevertToPointerRoot CurrentTime rot set-input-focus ;