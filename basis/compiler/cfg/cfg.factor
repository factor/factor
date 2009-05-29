! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays vectors accessors
namespaces make fry sequences ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
id
number
{ instructions vector }
{ successors vector }
{ predecessors vector } ;

M: basic-block hashcode* nip id>> ;

: <basic-block> ( -- bb )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors
        \ basic-block counter >>id ;

: add-instructions ( bb quot -- )
    [ instructions>> building ] dip '[
        building get pop
        _ dip
        building get push
    ] with-variable ; inline

TUPLE: cfg { entry basic-block } word label spill-counts post-order ;

: <cfg> ( entry word label -- cfg ) f f cfg boa ;

TUPLE: mr { instructions array } word label ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
