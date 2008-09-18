! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces assocs sequences sets fry ;
IN: compiler.cfg

TUPLE: cfg entry word label ;

C: <cfg> cfg

! - "number" and "visited" is used by linearization.
TUPLE: basic-block < identity-tuple
visited
number
instructions
successors ;

: <basic-block> ( -- basic-block )
    basic-block new
        V{ } clone >>instructions
        V{ } clone >>successors ;

TUPLE: mr instructions word label frame-size spill-counts ;

: <mr> ( instructions word label -- mr )
    mr new
        swap >>label
        swap >>word
        swap >>instructions ;
