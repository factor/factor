IN: scratchpad
USE: inference
USE: lists
USE: math
USE: test
USE: logic
USE: combinators
USE: hashtables
USE: stack
USE: dataflow
USE: kernel
USE: vectors
USE: namespaces
USE: prettyprint

: dataflow-contains-op? ( object list -- ? )
    #! Check if some dataflow node contains a given operation.
    [ dupd node-op swap hash = ] some? nip ;

: dataflow-contains-param? ( object list -- ? )
    #! Check if some dataflow node contains a given operation.
    [ dupd node-param swap hash = ] some? nip ;

[ t ] [
    \ + [ 2 2 + ] dataflow dataflow-contains-param? >boolean
] unit-test

: inline-test
    car car ; inline

[ t ] [
    \ car [ inline-test ] dataflow dataflow-contains-param? >boolean
] unit-test

[ t ] [
    #ifte [ [ drop ] [ + ] ifte ] dataflow dataflow-contains-op? >boolean
] unit-test

: dataflow-consume-d-len ( object -- n )
    [ node-consume-d get vector-length ] bind ;

: dataflow-produce-d-len ( object -- n )
    [ node-produce-d get vector-length ] bind ;

[ t ] [ [ drop ] dataflow car dataflow-consume-d-len 1 = ] unit-test

[ t ] [ [ 2 ] dataflow car dataflow-produce-d-len 1 = ] unit-test

: dataflow-ifte-node-consume-d ( list -- node )
    #ifte swap dataflow-contains-op? car [ node-consume-d get ] bind ;

[ t ] [
    [ 2 [ swap ] [ nip "hi" ] ifte ] dataflow
    dataflow-ifte-node-consume-d vector-length 1 =
] unit-test

[ t ] [
    [ { drop no-method drop no-method } generic ] dataflow
    #generic swap dataflow-contains-op? car [
        node-param get [
            [ [ node-param get \ no-method = ] bind ] some?
        ] some?
    ] bind >boolean
] unit-test
