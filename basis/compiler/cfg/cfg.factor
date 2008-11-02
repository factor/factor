! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays accessors namespaces assocs sequences sets fry ;
IN: compiler.cfg

TUPLE: cfg entry word label ;

C: <cfg> cfg

TUPLE: basic-block < identity-tuple
id
number
instructions
successors ;

: <basic-block> ( -- basic-block )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors
        \ basic-block counter >>id ;

TUPLE: mr { instructions array } word label spill-counts ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
