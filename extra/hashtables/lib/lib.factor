
USING: kernel sequences assocs ;

IN: hashtables.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ref-hash ( table key -- value ) swap at ;

! set-hash with alternative stack effects

: put-hash* ( table key value -- ) spin set-at ;

: put-hash ( table key value -- table ) swap pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-hash-stack ( value key seq -- )
  dupd [ key? ] with find-last nip set-at ;
