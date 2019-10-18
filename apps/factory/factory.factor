! REQUIRES: libs/process libs/vocabs ;

USING: kernel parser io threads sequences x x.widgets wm.frame wm.root ; 

IN: factory

: start-factory ( display-string -- )

<dpy> >dpy

[ "X11 : error-handler called" print flush ] set-error-handler

init-window-table [ start-event-loop ] in-thread

init-drag-gc

<wm-root>

init-atoms

root children [ mapped? ] subset [ <frame> ] each

home "/.factory-rc" append dup exists?
[ run-file ] [ drop "apps/factory/factory-rc" resource-path run-file ] if

;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"apps/factory/factory.facts" resource-path run-file