! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel semantic-db semantic-db.type ;
IN: semantic-db.context

! contexts:
!  - have type 'context' in context 'semantic-db'

: current-context ( -- context-id )
    \ current-context get ;

: set-current-context ( context-id -- )
    \ current-context set ;

: context-id ( name -- context-id )
    context-type swap ensure-node-of-type ;

: with-context ( name quot -- )
    swap context-id [ set-current-context ] curry swap compose with-scope ;
