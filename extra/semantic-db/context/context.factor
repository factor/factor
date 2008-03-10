! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces semantic-db ;
IN: semantic-db.context

: create-context* ( context-name -- context-id ) create-node* ;
: create-context ( context-name -- ) create-context* drop ;

: context ( -- context-id )
    \ context get ;

: set-context ( context-id -- )
    \ context set ;

: with-context ( context-id quot -- )
    >r \ context r> with-variable ;
