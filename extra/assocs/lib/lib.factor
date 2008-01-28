USING: assocs kernel vectors sequences ;
IN: assocs.lib

: insert-at ( value key assoc -- )
    [ ?push ] change-at ;

: >set ( seq -- hash )
    [ dup ] H{ } map>assoc ;

: ref-at ( table key -- value ) swap at ;

! set-at with alternative stack effects

: put-at* ( table key value -- ) swap rot set-at ;

: put-at ( table key value -- table ) swap pick set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-assoc-stack ( value key seq -- )
  dupd [ key? ] with find-last nip set-at ;

: at-default ( key assoc -- value/key )
    dupd at [ nip ] when* ;

: at-peek ( key assoc -- value ? )
    at* dup >r [ peek ] when r> ;
