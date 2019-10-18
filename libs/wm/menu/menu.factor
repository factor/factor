
USING: kernel generic sequences x11 x x.widgets x.widgets.keymenu ;

IN: wm.menu

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-menu ;

C: wm-menu ( items -- wm-menu )
swap <keymenu> over set-delegate dup add-to-window-table ;

M: wm-menu handle-key-press ( event wm-menu -- )
dup unmap-window delegate handle-key-press ;

GENERIC: popup

M: wm-menu popup ( wm-menu -- )
dup map-window   dup raise
RevertToPointerRoot CurrentTime rot set-input-focus ;
