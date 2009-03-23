! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: classes.tuple kernel assocs accessors ;
IN: refs

TUPLE: ref assoc key ;

: >ref< ( ref -- key value ) [ key>> ] [ assoc>> ] bi ; inline

: delete-ref ( ref -- ) >ref< delete-at ;
GENERIC: get-ref ( ref -- obj )
GENERIC: set-ref ( obj ref -- )

TUPLE: key-ref < ref ;
C: <key-ref> key-ref
M: key-ref get-ref key>> ;
M: key-ref set-ref >ref< rename-at ;

TUPLE: value-ref < ref ;
C: <value-ref> value-ref
M: value-ref get-ref >ref< at ;
M: value-ref set-ref >ref< set-at ;
