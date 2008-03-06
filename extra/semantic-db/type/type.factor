! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: arrays db db.types kernel semantic-db sequences sequences.lib ;
IN: semantic-db.type

! types:
!  - have type 'type' in context 'semantic-db'
!  - have a context in context 'semantic-db'

: assign-type ( type nid -- arc-id )
    has-type-relation spin create-arc ;

: create-node-of-type ( type content -- node-id )
    create-node [ assign-type drop ] keep ;

: select-nodes-of-type ( type -- node-ids )
    ":type" INTEGER param
    has-type-relation ":has_type" INTEGER param 2array
    "select a.subject from arc a where a.relation = :has_type and a.object = :type"
    single-int-results ;

: select-node-of-type ( type -- node-id )
    select-nodes-of-type ?first ;

: select-nodes-of-type-with-content ( type content -- node-ids )
    ! find nodes with the given content that are the subjects of arcs with:
    !     relation = has-type-relation
    !     object = type
    ":name" TEXT param
    swap ":type" INTEGER param
    has-type-relation ":has_type" INTEGER param 3array
    "select n.id from node n, arc a where n.content = :name and n.id = a.subject and a.object = :type and a.relation = :has_type"
    single-int-results ;

: select-node-of-type-with-content ( type content -- node-id/f )
    select-nodes-of-type-with-content 1result ;

: ensure-node-of-type ( type content -- node-id )
    [ select-node-of-type-with-content ] [ create-node-of-type ] ensure2 ;
    ! 2dup select-node-of-type-with-content [ 2nip ] [ create-node-of-type ] if* ;


: ensure-type ( type -- node-id )
    dup "type" = [
        drop type-type
    ] [
        type-type swap ensure-node-of-type
    ] if ;
