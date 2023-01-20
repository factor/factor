! Copyright (C) 2007, 2008 Slava Pestov, 2009 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs boxes kernel math namespaces
slots.private ;
IN: refs

MIXIN: ref

GENERIC: get-ref ( ref -- obj )
GENERIC: set-ref ( obj ref -- )
GENERIC: delete-ref ( ref -- )

! works like >>slot words
: set-ref* ( ref obj -- ref ) over set-ref ;

! very similar to change, on, off, +@, inc, and dec from namespaces
: change-ref ( ref quot -- )
    [ [ get-ref ] keep ] dip dip set-ref ; inline
: ref-on ( ref -- ) t swap set-ref ;
: ref-off ( ref -- ) f swap set-ref ;
: ref-+@ ( n ref -- ) [ 0 or + ] change-ref ;
: ref-inc ( ref -- ) 1 swap ref-+@ ;
: ref-dec ( ref -- ) -1 swap ref-+@ ;

: take ( ref -- obj )
    [ get-ref ] [ delete-ref ] bi ;

! delete-ref defaults to setting ref to f
M: ref delete-ref ref-off ;

TUPLE: obj-ref obj ;
C: <obj-ref> obj-ref
M: obj-ref get-ref obj>> ;
M: obj-ref set-ref obj<< ;
INSTANCE: obj-ref ref

TUPLE: var-ref var ;
C: <var-ref> var-ref
M: var-ref get-ref var>> get ;
M: var-ref set-ref var>> set ;
INSTANCE: var-ref ref

TUPLE: global-var-ref var ;
C: <global-var-ref> global-var-ref
M: global-var-ref get-ref var>> get-global ;
M: global-var-ref set-ref var>> set-global ;
INSTANCE: global-var-ref ref

TUPLE: slot-ref tuple slot ;
C: <slot-ref> slot-ref
: >slot-ref< ( slot-ref -- tuple slot ) [ tuple>> ] [ slot>> ] bi ; inline
M: slot-ref get-ref >slot-ref< slot ;
M: slot-ref set-ref >slot-ref< set-slot ;
INSTANCE: slot-ref ref

M: box get-ref box> ;
M: box set-ref >box ;
M: box delete-ref box> drop ;
INSTANCE: box ref

TUPLE: assoc-ref assoc key ;
: >assoc-ref< ( assoc-ref -- key value ) [ key>> ] [ assoc>> ] bi ; inline
M: assoc-ref delete-ref >assoc-ref< delete-at ;

TUPLE: key-ref < assoc-ref ;
C: <key-ref> key-ref
M: key-ref get-ref key>> ;
M: key-ref set-ref >assoc-ref< rename-at ;
INSTANCE: key-ref ref

TUPLE: value-ref < assoc-ref ;
C: <value-ref> value-ref
M: value-ref get-ref >assoc-ref< at ;
M: value-ref set-ref >assoc-ref< set-at ;
INSTANCE: value-ref ref
