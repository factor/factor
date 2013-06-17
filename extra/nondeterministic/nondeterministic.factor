! Copyright (C) 2013 Ales Guzik.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel namespaces continuations combinators.smart sequences lists locals ;
IN: nondeterministic

<PRIVATE

SYMBOL: paths
SYMBOL: fail-at
nil paths set-global
: push-history-path ( cc-quot -- ) paths get cons paths set ;

PRIVATE>

: fail-here ( -- ) [ fail-at set ] callcc0 ;

: fail ( -- * )
  paths get [ nil? not ]
    [ uncons paths set call( -- * ) ]
    [ fail-at get continue ]
  smart-if* ;

: choose-list ( choices-list -- current-choice )
  [ nil? not ]
  [
    [| cc seq |
      [ seq cdr choose-list cc continue-with ] push-history-path
      seq car
    ] curry callcc1
  ] [ fail ] smart-if* ;

: choose ( choices-seq -- current-choice ) sequence>list choose-list ;
