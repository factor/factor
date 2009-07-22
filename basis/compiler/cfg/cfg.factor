! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math vectors arrays accessors namespaces ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
{ id integer }
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

TUPLE: cfg { entry basic-block } word label spill-counts post-order ;

: <cfg> ( entry word label -- cfg ) f f cfg boa ;

: cfg-changed ( cfg -- cfg ) f >>post-order ; inline

TUPLE: mr { instructions array } word label ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
