
USING: kernel alien.c-types sequences math unix combinators.cleave ;

IN: unix.process

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: >argv ( seq -- alien ) [ malloc-char-string ] map f add >c-void*-array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: exec ( pathname argv -- int )
  [ malloc-char-string ] [ >argv ] bi* execv ;

: exec-with-path ( filename argv -- int )
  [ malloc-char-string ] [ >argv ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
  [ malloc-char-string ] [ >argv ] [ >argv ] tri* execve ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: exec-args           ( seq -- int ) [ first ] [ ] bi exec ;
: exec-args-with-path ( seq -- int ) [ first ] [ ] bi exec-with-path ;

: exec-args-with-env  ( seq seq -- int ) >r [ first ] [ ] bi r> exec-with-env ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-fork ( child parent -- ) fork dup zero? -roll swap curry if ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: kernel alien.c-types namespaces continuations threads assocs unix
       combinators.cleave ;

SYMBOL: pid-wait

! KEY | VALUE
! -----------
! pid | continuation

: init-pid-wait ( -- ) H{ } clone pid-wait set-global ;

: wait-for-pid ( pid -- status ) [ pid-wait get set-at stop ] curry callcc1 ;

: wait-loop ( -- )
  -1 0 <int> tuck WNOHANG waitpid               ! &status return
  [ *int ] [ pid-wait get delete-at* drop ] bi* ! status ?
  dup [ schedule-thread-with ] [ 2drop ] if
  250 sleep wait-loop ;

: start-wait-loop ( -- ) init-pid-wait [ wait-loop ] in-thread ;