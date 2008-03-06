! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel semantic-db semantic-db.context semantic-db.type ;
IN: semantic-db.relations

! relations:
!  - have type 'relation' in context 'semantic-db'
!  - have a context in context 'semantic-db'

: create-relation ( context-id relation-name -- relation-id )
    relation-type swap ensure-node-of-type
    tuck has-context-relation spin create-arc ;

: select-relation ( context-id relation-name -- relation-id/f )
    [
        ":name" TEXT param ,
        has-type-relation ":has_type" INTEGER param ,
        relation-type ":relation_type" INTEGER param ,
        ":context" INTEGER param ,
        has-context-relation ":has_context" INTEGER param ,
    ] { } make
    "select n.id from node n, arc a, arc b where n.content = :name and n.id = a.subject and a.relation = :has_type and a.object = :relation_type and n.id = b.subject and b.relation = :has_context and b.object = :context"
    single-int-results ;

: relation-id ( context-id relation-name -- relation-id )
    [ select-relation ] [ create-relation ] ensure2 ;
    ! 2dup select-relation [ 2nip ] [ create-relation ] if* ;
