
USING: kernel hashtables sequences ;

IN: hashtables.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ref-hash ( table key -- value ) swap hash ;

! set-hash with alternative stack effects

: put-hash* ( table key value -- ) swap rot set-hash ;

: put-hash ( table key value -- table ) swap pick set-hash ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-hash-stack ( value key seq -- )
dupd [ hash-member? ] find-last-with nip set-hash ;
