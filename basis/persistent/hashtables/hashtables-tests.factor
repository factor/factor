IN: persistent.hashtables.tests
USING: persistent.hashtables persistent.assocs hashtables assocs
tools.test kernel namespaces random math.ranges sequences fry ;

[ t ] [ PH{ } assoc-empty? ] unit-test

[ PH{ { "A" "B" } } ] [ PH{ } "B" "A" rot new-at ] unit-test

[ "B" ] [ "A" PH{ { "A" "B" } } at ] unit-test

[ f ] [ "X" PH{ { "A" "B" } } at ] unit-test

! We have to define these first so that they're compiled before
! the below hashtables are parsed...
<<

TUPLE: hash-0-a ;

M: hash-0-a hashcode* 2drop 0 ;

TUPLE: hash-0-b ;

M: hash-0-b hashcode* 2drop 0 ;

>>

[ ] [
    PH{ }
    "a" T{ hash-0-a } rot new-at
    "b" T{ hash-0-b } rot new-at
    "ph" set
] unit-test

[
    H{
        { T{ hash-0-a } "a" }
        { T{ hash-0-b } "b" }
    }
] [ "ph" get >hashtable ] unit-test
 
[
    H{
        { T{ hash-0-b } "b" }
    }
] [ "ph" get T{ hash-0-a } swap pluck-at >hashtable ] unit-test

[
    H{
        { T{ hash-0-a } "a" }
    }
] [ "ph" get T{ hash-0-b } swap pluck-at >hashtable ] unit-test

[
    H{
        { T{ hash-0-a } "a" }
        { T{ hash-0-b } "b" }
    }
] [ "ph" get "X" swap pluck-at >hashtable ] unit-test

[ ] [
    PH{ }
    "B" "A" rot new-at
    "D" "C" rot new-at
    "ph" set
] unit-test

[ H{ { "A" "B" } { "C" "D" } } ] [
    "ph" get >hashtable
] unit-test

[ H{ { "C" "D" } } ] [
    "ph" get "A" swap pluck-at >hashtable
] unit-test

[ H{ { "A" "B" } { "C" "D" } { "E" "F" } } ] [
    "ph" get "F" "E" rot new-at >hashtable
] unit-test

[ H{ { "C" "D" } { "E" "F" } } ] [
    "ph" get "F" "E" rot new-at "A" swap pluck-at >hashtable
] unit-test

: random-string ( -- str )
    1000000 random ; ! [ CHAR: a CHAR: z [a,b] random ] "" replicate-as ;

: random-assocs ( n -- hash phash )
    [ random-string ] replicate
    [ H{ } clone [ '[ swap _ set-at ] each-index ] keep ]
    [ PH{ } clone swap [ spin new-at ] each-index ]
    bi ;

: ok? ( assoc1 assoc2 -- ? )
    [ assoc= ] [ [ assoc-size ] bi@ = ] 2bi and ;

: test-persistent-hashtables-1 ( n -- ? )
    random-assocs ok? ;

[ t ] [ 10 test-persistent-hashtables-1 ] unit-test
[ t ] [ 20 test-persistent-hashtables-1 ] unit-test
[ t ] [ 30 test-persistent-hashtables-1 ] unit-test
[ t ] [ 50 test-persistent-hashtables-1 ] unit-test
[ t ] [ 100 test-persistent-hashtables-1 ] unit-test
[ t ] [ 500 test-persistent-hashtables-1 ] unit-test
[ t ] [ 1000 test-persistent-hashtables-1 ] unit-test
[ t ] [ 5000 test-persistent-hashtables-1 ] unit-test
[ t ] [ 10000 test-persistent-hashtables-1 ] unit-test
[ t ] [ 50000 test-persistent-hashtables-1 ] unit-test

: test-persistent-hashtables-2 ( n -- ? )
    random-assocs
    dup keys [
        [ nip over delete-at ] [ swap pluck-at nip ] 3bi
        2dup ok?
    ] all? 2nip ;

[ t ] [ 6000 test-persistent-hashtables-2 ] unit-test
