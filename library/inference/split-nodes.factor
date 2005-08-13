IN: inference
USING: kernel sequences words ;

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

: split-branch ( node -- )
    dup node-successor over node-children [
        [ last-node >r clone-node r> set-node-successor ] keep
        split-node
    ] each-with f swap set-node-successor ;

M: #ifte split-node* ( node -- )
    split-branch ;

M: #dispatch split-node* ( node -- )
    split-branch ;

M: #label split-node* ( node -- )
    node-children first split-node ;

: post-inline ( #return/#values #call/#merge -- )
    [ >r node-in-d r> node-out-d unify-length ] keep
    node-successor subst-values ;

: subst-node ( old new -- )
    [ last-node 2dup swap post-inline set-node-successor ] keep
    split-node ;

: inline-literals ( node literals -- node )
    #! Make #push -> #return -> successor
    over drop-inputs [
        >r [ literalize ] map dataflow [ subst-node ] keep
        r> set-node-successor
    ] keep ;
