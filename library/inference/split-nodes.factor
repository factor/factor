IN: optimizer
USING: inference kernel sequences words ;

! #ifte --> X
!   |
!   +--> Y
!   |
!   +--> Z

! Becomes:

! #ifte
!   |
!   +--> Y --> X
!   |
!   +--> Z --> X

GENERIC: split-node* ( node -- )

: split-node ( node -- )
    [ dup split-node* node-successor split-node ] when* ;

M: node split-node* ( node -- ) drop ;

: post-inline ( #return/#values #call/#merge -- )
    dup [
        [ >r node-in-d r> node-out-d unify-length ] keep
        node-successor subst-values
    ] [
        2drop
    ] ifte ;

: subst-node ( old new -- )
    #! The last node of 'new' becomes 'old', then values are
    #! substituted. A subsequent optimizer phase kills the
    #! last node of 'new' and the first node of 'old'.
    [ last-node 2dup swap post-inline set-node-successor ] keep
    split-node ;

: split-branch ( node -- )
    dup node-successor over node-children
    [ >r clone-node r> subst-node ] each-with
    f swap set-node-successor ;

M: #ifte split-node* ( node -- )
    split-branch ;

M: #dispatch split-node* ( node -- )
    split-branch ;

! #label
M: #label split-node* ( node -- )
    node-child split-node ;

: inline-literals ( node literals -- node )
    #! Make #push -> #return -> successor
    over drop-inputs [
        >r [ literalize ] map dataflow [ subst-node ] keep
        r> set-node-successor
    ] keep ;
