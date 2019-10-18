USE: random
USE: kernel
USE: lists
USE: math
USE: test
USE: namespaces

: nth ( n list -- list[n] )
    #! nth element of a proper list.
    #! Supplying n <= 0 pushes the first element of the list.
    #! Supplying an argument beyond the end of the list raises
    #! an error.
    swap [ cdr ] times car ;

: random-element ( list -- random )
    #! Returns a random element from the given list.
    dup >r length pred 0 swap random-int r> nth ;

: random-subset ( list -- list )
    #! Returns a random subset of the given list. Each item is
    #! chosen with a 50%
    #! probability.
    [ drop random-boolean ] subset ;

: car+ ( list -- sum )
    #! Adds the car of each element of the given list.
    0 swap [ car + ] each ;

: random-probability ( list -- sum )
    #! Adds the car of each element of the given list, and
    #! returns a random number between 1 and this sum.
    1 swap car+ random-int ;

: random-element-iter ( list index -- elem )
    #! Used by random-element*. Do not call directly.
    >r unswons unswons r>   ( list elem probability index )
    swap -                  ( list elem index )
    dup 0 <= [
        drop nip
    ] [
        nip random-element-iter
    ] ifte ;

: random-element* ( list -- elem )
    #! Returns a random element of the given list of comma
    #! pairs. The car of each pair is a probability, the cdr is
    #! the item itself. Only the cdr of the comma pair is
    #! returned.
    dup 1 swap car+ random-int random-element-iter ;

: random-subset* ( list -- list )
    #! Returns a random subset of the given list of comma pairs.
    #! The car of each pair is a probability, the cdr is the
    #! item itself. Only the cdr of the comma pair is returned.
    [
        [ car+ ] keep ( probabilitySum list )
        [
            >r 1 over random-int r> ( probabilitySum probability elem )
            uncons ( probabilitySum probability elema elemd )
            -rot ( probabilitySum elemd probability elema )
            > ( probabilitySum elemd boolean )
            [ drop ] [ , ] ifte
        ] each drop
    ] make-list ;

: check-random-subset ( expected pairs -- )
    random-subset* [ over contains? ] all? nip ;

[
    [ t ]
    [ [ 1 2 3 ] random-element number? ]
    unit-test
    
    [
        [ 10 | t ]
        [ 20 | f ]
        [ 30 | "monkey" ]
        [ 24 | 1/2 ]
        [ 13 | { "Hello" "Banana" } ]
    ] "random-pairs" set
    
    "random-pairs" get [ cdr ] map "random-values" set
    
    [ f ]
    [
        "random-pairs" get
        random-element* "random-values" get contains? not
    ] unit-test
    
    [ t ] [
        "random-values" get
        "random-pairs" get
        check-random-subset
    ] unit-test

    [ 1 ] [  -1 [ 1 2 ] nth ] unit-test
    [ 1 ] [  0  [ 1 2 ] nth ] unit-test
    [ 2 ] [  1  [ 1 2 ] nth ] unit-test
] with-scope
