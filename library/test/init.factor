IN: temporary
USE: namespaces
USE: test
USE: kernel
USE: hashtables

[
    [ f ] [ "-no-user-init" cli-arg ] unit-test
    [ f ] [ "user-init" get ] unit-test

    [ f ] [ "-user-init" cli-arg ] unit-test
    [ t ] [ "user-init" get ] unit-test
    
    [ "sdl.factor" ] [ "sdl.factor" cli-arg ] unit-test
] with-scope

: traverse-path ( name object -- object )
    dup hashtable? [ hash ] [ 2drop f ] if ;

: (object-path) ( object list -- object )
    [ uncons >r swap traverse-path r> (object-path) ] when* ;

: object-path ( list -- object )
    #! An object path is a list of strings. Each string is a
    #! variable name in the object namespace at that level.
    #! Returns f if any of the objects are not set.
    namespace swap (object-path) ;

[
    5 [ "test" "object" "path" ] set-path
    [ 5 ] [ [ "test" "object" "path" ] object-path ] unit-test

    7 [ "test" "object" "pathe" ] set-path
    [ 7 ] [ [ "test" "object" "pathe" ] object-path ] unit-test

    9 [ "teste" "object" "pathe" ] set-path
    [ 9 ] [ [ "teste" "object" "pathe" ] object-path ] unit-test
] with-scope
