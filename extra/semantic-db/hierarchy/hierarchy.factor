! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel new-slots semantic-db semantic-db.relations sequences ;
IN: semantic-db.hierarchy

TUPLE: tree id children ;
C: <tree> tree

! TODO: don't use context here. Hierarchies should be created within
! arbitrary contexts.
: hierarchy-context ( -- context-id )
    "hierarchy" context-id ;

: has-parent-relation ( -- relation-id )
    hierarchy-context "has parent" relation-id ;

: parent-of ( parent child -- arc-id )
    has-parent-relation spin create-arc ;

: select-parents ( child -- parents )


: ensure-parent ( child parent -- )
    ! TODO
    ;

: find-children ( node-id -- children )
    ! find arcs with:
    !   relation = has-parent-relation
    !   object = node-id
    ! then load the subjects either as nodes or subtrees
    ":node_id" INTEGER param
    has-parent-relation ":has_parent" INTEGER param 2array
    "select a.subject from arc a where relation = :has_parent and object = :node_id"
    single-int-results ;

: get-node-hierarchy ( node-id -- tree )
    dup find-children <tree> ;
