! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compiler.cfg.stack-frame kernel layouts math
namespaces vectors ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
    number
    { instructions vector }
    { successors vector }
    { predecessors vector }
    { kill-block? boolean }
    height
    replaces
    peeks
    kills ;

: <basic-block> ( -- bb )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors ;

TUPLE: cfg
    { entry basic-block }
    word
    label
    stack-frame
    frame-pointer?
    post-order linear-order
    predecessors-valid? dominance-valid? loops-valid? ;

: <cfg> ( word label entry -- cfg )
    cfg new
        swap >>entry
        swap >>label
        swap >>word
        stack-frame new cell >>spill-area-align >>stack-frame ;

: cfg-changed ( cfg -- )
    f >>post-order
    f >>linear-order
    f >>dominance-valid?
    f >>loops-valid? drop ; inline

: predecessors-changed ( cfg -- )
    f >>predecessors-valid? drop ;

: with-cfg ( ..a cfg quot: ( ..a cfg -- ..b ) -- ..b )
    [ dup cfg ] dip with-variable ; inline

: local-allot-offset ( n -- offset )
    cfg get stack-frame>> allot-area-base>> + ;

: spill-offset ( n -- offset )
    cfg get stack-frame>> spill-area-base>> + ;
