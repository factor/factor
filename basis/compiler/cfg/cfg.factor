! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel layouts math namespaces vectors ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
    number
    { instructions vector }
    { successors vector }
    { predecessors vector }
    { kill-block? boolean } ;

: <basic-block> ( -- bb )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors ;

TUPLE: cfg
    { entry basic-block }
    word
    label
    { spill-area-size integer }
    { spill-area-align integer }
    stack-frame
    frame-pointer?
    post-order linear-order
    predecessors-valid? dominance-valid? loops-valid? ;

: <cfg> ( word label entry -- cfg )
    cfg new
        swap >>entry
        swap >>label
        swap >>word
        0 >>spill-area-size
        cell >>spill-area-align ;

: cfg-changed ( cfg -- )
    f >>post-order
    f >>linear-order
    f >>dominance-valid?
    f >>loops-valid? drop ; inline

: predecessors-changed ( cfg -- )
    f >>predecessors-valid? drop ;

: with-cfg ( ..a cfg quot: ( ..a cfg -- ..b ) -- ..b )
    [ dup cfg ] dip with-variable ; inline
