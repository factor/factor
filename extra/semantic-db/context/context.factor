! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: semantic-db.db ;
IN: semantic-db.context

: all-contexts ( -- contexts )
    has-type-relation context-type relation-object-subjects ;

: context-relations ( context -- relations )
    has-context-relation swap relation-object-subjects ;
    
: get-context ( name -- context )
    context-type swap ensure-node-of-type ;

