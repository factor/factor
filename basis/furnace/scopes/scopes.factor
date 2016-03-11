! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs db2.types destructors furnace.cache
kernel orm.persistent orm.tuples ;
IN: furnace.scopes

TUPLE: scope < server-state namespace changed? ;

: empty-scope ( class -- scope )
    f swap new-server-state
        H{ } clone >>namespace ; inline

PERSISTENT: scope
    { "namespace" FACTOR-BLOB +not-null+ } ;

: scope-changed ( scope -- )
    t >>changed? drop ;

: scope-get ( key scope -- value )
    [ namespace>> at ] [ drop f ] if* ;

: scope-set ( value key scope -- )
    [ namespace>> set-at ] [ scope-changed ] bi ;

: scope-change ( key quot scope -- )
    [ namespace>> swap change-at ] [ scope-changed ] bi ; inline

! Destructor
TUPLE: scope-saver scope manager ;

C: <scope-saver> scope-saver

M: scope-saver dispose
    [ manager>> ] [ scope>> ] bi
    dup changed?>> [
        [ swap touch-state ] [ update-tuple ] bi
    ] [ 2drop ] if ;

: save-scope-after ( scope manager -- )
    <scope-saver> &dispose drop ;
