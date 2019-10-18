
USING: kernel generic x11 x x.widgets ;

IN: wm.child

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: child ;

C: child ( window -- child )
tuck set-delegate dup add-to-window-table
dup add-to-save-set
0 over set-border-width
{ PropertyChangeMask } over select-input ;

! M: child handle-property ( event child -- ) 2drop ;

! M: child handle-property ( event child -- )
! nip parent dup wm-frame? [ update-title ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! VARS: child event ;

! M: child handle-property ( event child -- ) [ >child >event
! "child handle-property :: atom name = " write
! event> XPropertyEvent-atom get-atom-name print flush ;

USE: io

M: child handle-property ( event child -- )
drop
"child handle-property :: atom name = " write
XPropertyEvent-atom get-atom-name print flush ;