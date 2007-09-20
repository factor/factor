! Copyright (C) 2005 Chris Double, 2007 Clemens Hofreither.
! See http://factorcode.org/license.txt for BSD license.
IN: coroutines
USING: kernel hashtables namespaces continuations quotations ;

SYMBOL: current-coro

TUPLE: coroutine resumecc exitcc ;

: cocreate ( quot -- co )
  coroutine construct-empty
  dup current-coro associate
  [ swapd , , \ bind , 
    "Coroutine has terminated illegally." , \ throw ,
  ] [ ] make
  over set-coroutine-resumecc ;

: coresume ( v co -- result )
  [ 
    over set-coroutine-exitcc
    coroutine-resumecc call
    #! At this point, the coroutine quotation must have terminated
    #! normally (without calling coyield or coterminate). This shouldn't happen.
    f over
  ] callcc1 2nip ;

: coresume* ( v co -- ) coresume drop ; inline
: *coresume ( co -- result ) f swap coresume ; inline

: coyield ( v -- result )
  current-coro get
  [  
    [ continue-with ] curry
    over set-coroutine-resumecc  
    coroutine-exitcc continue-with
  ] callcc1 2nip ;

: coyield* ( v -- ) coyield drop ; inline
: *coyield ( -- v ) f coyield ; inline

: coterminate ( v -- )
  current-coro get
  f over set-coroutine-resumecc
  coroutine-exitcc continue-with ;
