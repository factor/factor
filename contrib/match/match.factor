! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Based on pattern matching code from Paul Graham's book 'On Lisp'.
IN: match
USING: kernel words sequences namespaces hashtables parser ;

SYMBOL: _
USE: prettyprint

: define-match-var ( name -- )
  create-in [ dup <wrapper> , \ get , ] [ ] make define-compound ;

: define-match-vars ( seq -- )
  [ define-match-var ] each ;

: MATCH-VARS: ! vars ...
  string-mode on [ string-mode off define-match-vars ] f ; parsing

: match-var? ( symbol -- bool )
  dup word? [
    word-name first CHAR: ? = 
  ] [
    drop f
  ] if ;

: (match) ( seq1 seq2 -- matched? )
  {
    { [ 2dup = ] [ 2drop t ] }
    { [ over _ = ] [ 2drop t ] } 
    { [ dup _ = ] [ 2drop t ] }
    { [ dup match-var? ] [ set t ] }
    { [ over match-var? ] [ swap set t ] }
    { [ over sequence? over sequence? and [ over first over first (match) ] [ f ] if ] [ >r 1 tail r> 1 tail (match) ] }
    { [ t ] [ 2drop f ] }
  } cond ;

: match ( seq1 seq2 -- bindings )
  [ (match) ] make-hash swap [ drop f ] unless ;

SYMBOL: result

: match-cond ( seq assoc -- )
  [
    [ first over match dup result set ] find 2nip dup [ result get [ second call ] bind ] [ no-cond ] if 
  ] with-scope ;
