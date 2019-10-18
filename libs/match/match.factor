! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Based on pattern matching code from Paul Graham's book 'On Lisp'.
IN: match
USING: errors generic hashtables inference kernel namespaces
parser sequences words ;

SYMBOL: _
USE: prettyprint

: define-match-var ( name -- )
    create-in dup t "match-var" set-word-prop [
        dup <wrapper> , \ get ,
    ] [ ] make define-compound ;

: define-match-vars ( seq -- )
    [ define-match-var ] each ;

: MATCH-VARS: ! vars ...
    ";" parse-tokens define-match-vars ; parsing

: match-var? ( symbol -- bool )
    dup word? [
        "match-var" word-prop
    ] [
        drop f
    ] if ;

: [&&] ( seq -- quot )
    dup empty? [
        drop [ drop t ]
    ] [
        [
            unclip
            \ dup , % [&&] , [ drop f ] , \ if ,
        ] [ ] make
    ] if ;

: && ( obj seq -- ? ) [&&] call ;

\ && 1 [ [&&] ] define-transform

: (match) ( seq1 seq2 -- matched? )
    {
        { [ dup match-var? ] [ set t ] }
        { [ over match-var? ] [ swap set t ] }
        { [ 2dup = ] [ 2drop t ] }
        { [ over _ = ] [ 2drop t ] }
        { [ dup _ = ] [ 2drop t ] }
        { [ over { [ sequence? ] [ empty? not ] }
            && over { [ sequence? ] [ empty? not ] }
            && and [ over first over first (match) ] [ f ] if ]
            [ >r 1 tail r> 1 tail (match) ] }
        { [ over tuple? over tuple? and ]
            [ >r tuple>array r> tuple>array (match) ] }
        { [ t ] [ 2drop f ] }
    } cond ;

: match ( seq1 seq2 -- bindings )
    [ (match) ] H{ } make-assoc swap [ drop f ] unless ;

SYMBOL: result

: [match-cond] ( seq -- quot )
    dup empty? [
        drop [ drop "Fall-through in match-cond" throw ]
    ] [
        [
            unclip
            \ dup , dup first <wrapper> , \ match , second
            [ \ nip , , \ bind , ] [ ] make ,
            [match-cond] , \ if* ,
        ] [ ] make
    ] if ;

: match-cond ( seq assoc -- )
    [match-cond] call ;

\ match-cond 1 [ [match-cond] ] define-transform

: replace-patterns ( object -- result )
    {
        { [ dup match-var? ] [ get ] }
        { [ dup sequence? ]
            [ [ [ replace-patterns , ] each ] over make ] }
        { [ dup tuple? ]
            [ tuple>array replace-patterns >tuple ] }
        { [ t ] [ ] }
    } cond ;

: match-replace ( object pattern1 pattern2 -- result )
    -rot match [ replace-patterns ] bind ;
