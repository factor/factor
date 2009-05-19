! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays vectors accessors namespaces ;
IN: compiler.cfg

TUPLE: basic-block < identity-tuple
id
number
{ instructions vector }
{ successors vector }
{ predecessors vector } ;

M: basic-block hashcode* nip id>> ;

: <basic-block> ( -- basic-block )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        V{ } clone >>predecessors
        \ basic-block counter >>id ;

TUPLE: cfg { entry basic-block } word label ;

C: <cfg> cfg

TUPLE: mr { instructions array } word label spill-counts ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
