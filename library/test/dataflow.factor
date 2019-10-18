IN: scratchpad
USE: inference
USE: lists
USE: math
USE: test
USE: hashtables
USE: kernel
USE: vectors
USE: namespaces
USE: prettyprint
USE: words
USE: kernel
USE: kernel-internals
USE: generic

: dataflow-contains-op? ( object list -- ? )
    #! Check if some dataflow node contains a given operation.
    [ node-op swap hash = ] some-with? ;

: dataflow-contains-param? ( object list -- ? )
    #! Check if some dataflow node contains a given operation.
    [
        [
            node-op get #label = [
                node-param get dataflow-contains-param?
            ] [
                node-param get =
            ] ifte
        ] bind
    ] some-with? ;

[ t ] [
    \ + [ 2 2 + ] dataflow dataflow-contains-param? >boolean
] unit-test

: inline-test
    car car ; inline

! [ t ] [
!     \ slot [ inline-test ] dataflow dataflow-contains-param? >boolean
! ] unit-test

[ t ] [
    \ ifte [ [ drop ] [ + ] ifte ] dataflow dataflow-contains-op? >boolean
] unit-test

: dataflow-consume-d-len ( object -- n )
    [ node-consume-d get length ] bind ;

: dataflow-produce-d-len ( object -- n )
    [ node-produce-d get length ] bind ;

[ t ] [ [ drop ] dataflow car dataflow-consume-d-len 1 = ] unit-test

[ t ] [ [ 2 ] dataflow car dataflow-produce-d-len 1 = ] unit-test

: dataflow-ifte-node-consume-d ( list -- node )
    \ ifte swap dataflow-contains-op? car [ node-consume-d get ] bind ;

[ t ] [
    [ [ swap ] [ nip "hi" ] ifte ] dataflow
    dataflow-ifte-node-consume-d length 1 =
] unit-test

! [ t ] [
!     [ { [ drop ] [ undefined-method ] [ drop ] [ undefined-method ] } generic ] dataflow
!     \ dispatch swap dataflow-contains-op? car [
!         node-param get [
!             [ [ node-param get \ undefined-method = ] bind ] some?
!         ] some?
!     ] bind >boolean
! ] unit-test

SYMBOL: #test

#test f "foobar" set-word-property

[ 6 ] [
    {{
        [[ node-op #test ]]
        [[ node-param 5 ]]
    }} "foobar" [ [ node-param get ] bind 1 + ] apply-dataflow
] unit-test

#test [ [ node-param get ] bind sq ] "foobar" set-word-property

[ 25 ] [
    {{
        [[ node-op #test ]]
        [[ node-param 5 ]]
    }} "foobar" [ [ node-param get ] bind 1 + ] apply-dataflow
] unit-test

! Somebody (cough) got the order of ifte nodes wrong.

[ t ] [
    \ ifte [ [ 1 ] [ 2 ] ifte ] dataflow dataflow-contains-op? car
    [ node-param get ] bind car car [ node-param get ] bind 1 =
] unit-test
