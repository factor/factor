! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel semantic-db sequences sequences.lib splitting ;
IN: tangle.path

RELATION: has-filename
RELATION: in-directory

: create-root ( -- node ) "" create-node ;

: get-root ( -- node )
    in-directory-relation ultimate-objects ?1node-result ;

: ensure-root ( -- node ) get-root [ create-root ] unless* ;

: create-file ( parent name -- node )
    create-node swap dupd in-directory ;

: files-in-directory ( node -- nodes ) in-directory-subjects ;

: file-in-directory ( name node -- node )
    in-directory-relation subjects-with-cor ?1node-result ;

: parent-directory ( file-node -- dir-node )
    in-directory-objects ?first ;

: (path>node) ( node name -- node )
    swap [ file-in-directory ] [ drop f ] if* ;

: path>node ( path -- node )
    ensure-root swap [ (path>node) ] each ;

: path>file ( path -- file )
    path>node [ has-filename-subjects ?first ] [ f ] if* ;

: (node>path) ( root seq node -- seq )
    pick over node= [
        drop nip
    ] [
        dup node-content pick push
        parent-directory [
            (node>path)
        ] [
            2drop f
        ] if*
    ] if ;

: node>path* ( root node -- path )
    V{ } clone swap (node>path) dup empty?
    [ drop f ] [ <reversed> ] if ;

: node>path ( node -- path )
    ensure-root swap node>path* ;

: file>path ( node -- path )
    has-filename-objects ?first [ node>path ] [ f ] if* ;
