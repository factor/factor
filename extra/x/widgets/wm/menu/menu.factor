
USING: kernel x11.constants mortar slot-accessors x.widgets.keymenu ;

IN: x.widgets.wm.menu

SYMBOL: <wm-menu>

<wm-menu> <keymenu> { } define-simple-class

<wm-menu> "create" !( <wm-menu> -- wm-menu )
  [ new-empty <- keymenu-init ]
add-class-method

<wm-menu> {

"wm-menu-handle-key-press" !( event wm-menu -- )
  [ <- unmap <- keymenu-handle-key-press ]

"handle-key-press" !( event wm-menu -- ) [ <- wm-menu-handle-key-press ]

"wm-menu-popup" !( wm-menu -- wm-menu )
  [ <- map <- raise RevertToPointerRoot CurrentTime <--- set-input-focus ]

"popup" !( wm-menu -- wm-menu ) [ <- wm-menu-popup ]

} add-methods