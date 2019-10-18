
USING: kernel parser io io.files namespaces sequences editors threads vars
       mortar slot-accessors
       x
       x.widgets.wm.root
       x.widgets.wm.frame 
       x.widgets.wm.menu
       factory.load
       factory.commands ;

IN: factory

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: manage-windows ( -- )
dpy get $default-root <- children [ <- mapped? ] subset
[ $id <wm-frame> new* drop ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: root-menu

: create-root-menu ( -- ) <wm-menu> new* 1 <-- set-border-width >root-menu ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-factory ( display-string -- )
<display> new* >dpy
install-default-error-handler
create-wm-root
init-atoms
manage-windows 
load-factory-rc ;

: factory ( -- ) f start-factory stop ;

MAIN: factory