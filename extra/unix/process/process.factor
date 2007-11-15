
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

! This is kludgy. We need a better implementation.

USE: threads

: wait-for-pid ( pid -- )
  dup "int" <c-object> WNOHANG waitpid
  0 = [ 100 sleep wait-for-pid ] [ drop ] if ;

