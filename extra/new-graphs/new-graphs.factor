! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel new-slots sequences vectors ;
IN: new-graphs

TUPLE: graph edges ;
TUPLE: digraph ;
TUPLE: undigraph ;

: <graph> ( -- graph )
    H{ } clone graph construct-boa H{ } clone over set-delegate ;

: <digraph> ( -- graph )
    <graph> digraph construct-empty tuck set-delegate ;

: <undigraph> ( -- graph )
    <graph> undigraph construct-empty tuck set-delegate ;

GENERIC: add-vertex ( key value graph -- )
M: graph add-vertex ( key value digraph -- ) set-at ; 

