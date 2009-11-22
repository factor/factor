USING: deques dlists dlists.private kernel tools.test random
assocs sets sequences namespaces sorting debugger io prettyprint
math accessors classes ;
IN: dlists.tests

[ t ] [ <dlist> deque-empty? ] unit-test

[ T{ dlist f T{ dlist-node f 1 f f } T{ dlist-node f 1 f f } } ]
[ <dlist> 1 over push-front ] unit-test

! Make sure empty lists are empty
[ t ] [ <dlist> deque-empty? ] unit-test
[ f ] [ <dlist> 1 over push-front deque-empty? ] unit-test
[ f ] [ <dlist> 1 over push-back deque-empty? ] unit-test

[ 1 ] [ <dlist> 1 over push-front pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-front pop-back ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-back ] unit-test
[ T{ dlist f f f } ] [ <dlist> 1 over push-front dup pop-front* ] unit-test
[ T{ dlist f f f } ] [ <dlist> 1 over push-front dup pop-back* ] unit-test
[ T{ dlist f f f } ] [ <dlist> 1 over push-back dup pop-front* ] unit-test
[ T{ dlist f f f } ] [ <dlist> 1 over push-back dup pop-back* ] unit-test

! Test the prev,next links for two nodes
[ f ] [
    <dlist> 1 over push-back 2 over push-back
    front>> prev>>
] unit-test

[ 2 ] [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> obj>>
] unit-test

[ 1 ] [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> prev>> obj>>
] unit-test

[ f ] [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> next>>
] unit-test

[ f f ] [ <dlist> [ 1 = ] dlist-find ] unit-test
[ 1 t ] [ <dlist> 1 over push-back [ 1 = ] dlist-find ] unit-test
[ f f ] [ <dlist> 1 over push-back [ 2 = ] dlist-find ] unit-test
[ f ] [ <dlist> 1 over push-back [ 2 = ] dlist-any? ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] dlist-any? ] unit-test

[ 1 ] [ <dlist> 1 over push-back [ 1 = ] delete-node-if ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop deque-empty? ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop deque-empty? ] unit-test

[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 4 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 5 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back* [ = ] curry dlist-find-node drop class dlist-node = ] unit-test
[ ] [ <dlist> 4 over push-back 5 over push-back [ drop ] dlist-each ] unit-test

[ <dlist> peek-front ] [ empty-dlist? ] must-fail-with
[ <dlist> peek-back ] [ empty-dlist? ] must-fail-with
[ <dlist> pop-front ] [ empty-dlist? ] must-fail-with
[ <dlist> pop-back ] [ empty-dlist? ] must-fail-with

[ t ] [ <dlist> 3 over push-front 4 over push-back 3 swap deque-member? ] unit-test

[ f ] [ <dlist> 3 over push-front 4 over push-back -1 swap deque-member? ] unit-test

[ f ] [ <dlist> 0 swap deque-member? ] unit-test

! Make sure clone does the right thing
[ V{ 2 1 } V{ 2 1 3 } ] [
    <dlist> 1 over push-front 2 over push-front
    dup clone 3 over push-back
    [ dlist>seq ] bi@
] unit-test

[ V{ f 3 1 f } ] [ <dlist> 1 over push-front 3 over push-front f over push-front f over push-back dlist>seq ] unit-test

[ V{ } ] [ <dlist> dlist>seq ] unit-test

[ V{ 0 2 4 } ] [ <dlist> { 0 1 2 3 4 } over push-all-back [ even? ] dlist-filter dlist>seq ] unit-test
[ V{ 2 4 } ] [ <dlist> { 1 2 3 4 } over push-all-back [ even? ] dlist-filter dlist>seq ] unit-test
[ V{ 2 4 } ] [ <dlist> { 1 2 3 4 5 } over push-all-back [ even? ] dlist-filter dlist>seq ] unit-test
[ V{ 0 2 4 } ] [ <dlist> { 0 1 2 3 4 5 } over push-all-back [ even? ] dlist-filter dlist>seq ] unit-test
