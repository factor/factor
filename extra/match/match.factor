! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Based on pattern matching code from Paul Graham's book 'On Lisp'.
USING: parser kernel words namespaces sequences tuples
combinators macros assocs ;
IN: match

SYMBOL: _

: define-match-var ( name -- )
    create-in
    dup t "match-var" set-word-prop
    dup [ get ] curry define-compound ;

: define-match-vars ( seq -- )
    [ define-match-var ] each ;

: MATCH-VARS: ! vars ...
    ";" parse-tokens define-match-vars ; parsing

: match-var? ( symbol -- bool )
    dup word? [ "match-var" word-prop ] [ drop f ] if ;

: set-match-var ( value var -- ? )
    dup namespace key? [ get = ] [ set t ] if ;

: (match) ( value1 value2 -- matched? )
    {
        { [ dup match-var? ] [ set-match-var ] }
        { [ over match-var? ] [ swap set-match-var ] }
        { [ 2dup = ] [ 2drop t ] }
        { [ 2dup [ _ eq? ] either? ] [ 2drop t ] }
        { [ 2dup [ sequence? ] both? ] [
            2dup [ length ] 2apply =
            [ [ (match) ] 2all? ] [ 2drop f ] if ] }
        { [ 2dup [ tuple? ] both? ]
          [ [ tuple>array ] 2apply [ (match) ] 2all? ] }
        { [ t ] [ 2drop f ] }
    } cond ;

: match ( value1 value2 -- bindings )
    [ (match) ] H{ } make-assoc swap [ drop f ] unless ;

MACRO: match-cond ( assoc -- )
    <reversed>
    [ "Fall-through in match-cond" throw ]
    [
        first2
        >r [ dupd match ] curry r>
        [ bind ] curry rot
        [ ?if ] 2curry append
    ] reduce ;

: replace-patterns ( object -- result )
    {
        { [ dup match-var? ] [ get ] }
        { [ dup sequence? ] [ [ replace-patterns ] map ] }
        { [ dup tuple? ] [ tuple>array replace-patterns >tuple ] }
        { [ t ] [ ] }
    } cond ;

: match-replace ( object pattern1 pattern2 -- result )
    -rot match [ replace-patterns ] bind ;
