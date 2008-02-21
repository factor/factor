! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel new-slots semantic-db semantic-db.context sequences ;
IN: semantic-db.hierarchy

TUPLE: tree id children ;
C: <tree> tree

: hierarchy-context ( -- context-id )
    "hierarchy" ensure-context ;

: has-parent-relation ( -- relation-id )
    ! find an arc with:
    !   type = relation (in semantic-db context)
    !   context = hierarchy
    !   name = "has parent"
    ;

: find-children ( node-id -- children )
    ! find arcs with:
    !   relation = has-parent-relation
    !   object = node-id
    ! then load the subjects either as nodes or subtrees
    ;

: get-node-hierarchy ( node-id -- tree )
    dup find-children <tree> ;
