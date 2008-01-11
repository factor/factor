USING: assocs kernel vectors sequences ;
IN: assocs.lib

: insert-at ( value key assoc -- )
    [ ?push ] change-at ;

: >set ( seq -- hash )
    [ dup ] H{ } map>assoc ;

: ref-hash ( table key -- value ) swap at ;

! set-hash with alternative stack effects

: put-hash* ( table key value -- ) swap rot set-at ;

: put-hash ( table key value -- table ) swap pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-hash-stack ( value key seq -- )
  dupd [ key? ] curry* find-last nip set-at ;

: at-default ( key assoc -- value/key )
    dupd at [ nip ] when* ;
