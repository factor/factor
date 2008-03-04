! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel semantic-db semantic-db.type ;
IN: semantic-db.context

! : all-contexts ( -- contexts )
!     has-type-relation context-type relation-object-subjects ;
! 
! : context-relations ( context -- relations )
!     has-context-relation swap relation-object-subjects ;

: ensure-context ( name -- context-id )
    context-type swap ensure-node-of-type ;

