! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces vectors ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
{ id integer }
number
{ instructions vector }
{ successors vector }
{ predecessors vector }
{ kill-block? boolean }
{ unlikely? boolean } ;

: <basic-block> ( -- bb )
    basic-block new
        \ basic-block counter >>id
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors ;

M: basic-block hashcode* nip id>> ;

TUPLE: cfg { entry basic-block } word label
spill-area-size spill-area-align
stack-frame
frame-pointer?
post-order linear-order
predecessors-valid? dominance-valid? loops-valid? ;

: <cfg> ( entry word label -- cfg )
    cfg new
        swap >>label
        swap >>word
        swap >>entry ;

: cfg-changed ( cfg -- )
    f >>post-order
    f >>linear-order
    f >>dominance-valid?
    f >>loops-valid? drop ; inline

: predecessors-changed ( cfg -- )
    f >>predecessors-valid? drop ;

: with-cfg ( ..a cfg quot: ( ..a cfg -- ..b ) -- ..b )
    [ dup cfg ] dip with-variable ; inline
