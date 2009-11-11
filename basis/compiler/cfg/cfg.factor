! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math vectors arrays accessors namespaces ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
number
{ instructions vector }
{ successors vector }
{ predecessors vector } ;

: <basic-block> ( -- bb )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors ;

TUPLE: cfg { entry basic-block } word label
spill-area-size reps
post-order linear-order
predecessors-valid? dominance-valid? loops-valid? ;

: <cfg> ( entry word label -- cfg )
    cfg new
        swap >>label
        swap >>word
        swap >>entry ;

: cfg-changed ( cfg -- cfg )
    f >>post-order
    f >>linear-order
    f >>dominance-valid?
    f >>loops-valid? ; inline

: predecessors-changed ( cfg -- cfg )
    f >>predecessors-valid? ;

: with-cfg ( cfg quot: ( cfg -- ) -- )
    [ dup cfg ] dip with-variable ; inline

TUPLE: mr { instructions array } word label ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
