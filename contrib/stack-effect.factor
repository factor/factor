IN: stack-effect
USE: lists
USE: stack
USE: math
USE: combinators
USE: kernel
USE: test
USE: errors

: s* ( [ a | b ] [ c | d ] )
    #! Stack effect composition.
    >r uncons r> uncons >r -
    dup 0 < [ neg + r> cons ] [ r> + cons ] ifte ;

: list* ( list [ a | b ] -- list )
    #! Right composition with a list and stack effect.
    swap [ over s* ] map nip prune ;

: *list ( [ a | b ] list -- list )
    #! Left composition with a list and stack effect.
    [ dupd s* ] map nip prune ;

: <> ( [ a | b ] )
    #! Stack height equivelence.
    uncons - ;

: balanced? ( list -- ? )
    #! Is this a balanced set?
    [ unswons <> swap [ <> over = ] all? nip ] [ t ] ifte* ;

: car> ( [ a | b ] [ c | d ] )
    swap car swap car > ;

: car-max ( [ a | b ] [ c | d ] )
    2dup car> [ drop ] [ nip ] ifte ;

: point ( list -- [ a | b ] )
    #! The point of a balanced set.
    [ -1 | -1 ] swap [ car-max ] each ;

: s+ ( [ a | b ] [ c | d ] -- )
    #! Stack effect addition.
    2list dup balanced? [ point ] [ "Not balanced" throw ] ifte ;

[ t ] [ [ [ 1 | 2 ] [ 3 | 4 ] ] balanced? ] unit-test
[ f ] [ [ [ 4 | 2 ] [ 3 | 4 ] ] balanced? ] unit-test
[ t ] [ [ [ 1 | 5 ] ] balanced? ] unit-test
[ t ] [ [ ] balanced? ] unit-test
[ [ 3 | 4 ] ] [ [ [ 1 | 2 ] [ 3 | 4 ] ] point ] unit-test

[ [ [ 1 | 1 ] [ 2 | 2 ] [ 3 | 3 ] ] ]
[ [ [ 1 | 2 ] [ 2 | 3 ] [ 3 | 4 ] ] [ 1 | 0 ] list* ] unit-test

[ [ 1 | 1 ] ] [ [ 1 | 2 ] [ 2 | 1 ] s* ] unit-test

[ [ 4 | 5 ] ] [ [ 4 | 5 ] [ 3 | 4 ] s+ ] unit-test
