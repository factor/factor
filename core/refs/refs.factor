! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: classes.tuple kernel assocs accessors ;
IN: refs

TUPLE: ref assoc key ;

: <ref> ( assoc key class -- tuple )
    >r ref construct-boa r> construct-delegate ; inline

: >ref< ( ref -- key assoc ) [ key>> ] [ assoc>> ] bi ;

: delete-ref ( ref -- ) >ref< delete-at ;
GENERIC: get-ref ( ref -- obj )
GENERIC: set-ref ( obj ref -- )

TUPLE: key-ref ;
: <key-ref> ( assoc key -- ref ) key-ref <ref> ;
M: key-ref get-ref ref-key ;
M: key-ref set-ref >ref< rename-at ;

TUPLE: value-ref ;
: <value-ref> ( assoc key -- ref ) value-ref <ref> ;
M: value-ref get-ref >ref< at ;
M: value-ref set-ref >ref< set-at ;
