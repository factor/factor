! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel semantic-db ;
IN: semantic-db.type

: assign-type ( type nid -- arc-id )
    has-type-relation spin create-arc ;

: create-node-of-type ( type name -- node-id )
    create-node [ assign-type drop ] keep ;

: select-node-of-type ( type name -- node-id? )
    ! find a node with the given name, that is the subject of an arc with:
    !     relation = has-type-relation
    !     object = type
    ;

: ensure-node-of-type ( type name -- node-id )
    2dup select-node-of-type [ 2nip ] [ create-node-of-type ] if* ;
