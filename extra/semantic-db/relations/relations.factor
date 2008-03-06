! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: db.types kernel namespaces semantic-db semantic-db.context
sequences.lib ;
IN: semantic-db.relations

! relations:
!  - have a context in context 'semantic-db'

: create-relation* ( context-id relation-name -- relation-id )
    create-node* tuck has-context-relation spin create-arc ;

: create-relation ( context-id relation-name -- )
    create-relation* drop ;

: get-relation ( context-id relation-name -- relation-id/f )
    [
        ":name" TEXT param ,
        ":context" INTEGER param ,
        has-context-relation ":has_context" INTEGER param ,
    ] { } make
    "select n.id from node n, arc a where n.content = :name and n.id = a.subject and a.relation = :has_context and a.object = :context"
    single-int-results ?first ;

: relation-id ( relation-name -- relation-id )
    context swap [ get-relation ] [ create-relation* ] ensure2 ;
