USING: dequeues dlists dlists.private kernel tools.test random
assocs sets sequences namespaces sorting debugger io prettyprint
math accessors classes ;
IN: dlists.tests

[ t ] [ <dlist> dequeue-empty? ] unit-test

[ T{ dlist f T{ dlist-node f 1 f f } T{ dlist-node f 1 f f } 1 } ]
[ <dlist> 1 over push-front ] unit-test

! Make sure empty lists are empty
[ t ] [ <dlist> dequeue-empty? ] unit-test
[ f ] [ <dlist> 1 over push-front dequeue-empty? ] unit-test
[ f ] [ <dlist> 1 over push-back dequeue-empty? ] unit-test

[ 1 ] [ <dlist> 1 over push-front pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-front pop-back ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-front ] unit-test
[ 1 ] [ <dlist> 1 over push-back pop-back ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-front dup pop-front* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-front dup pop-back* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-back dup pop-front* ] unit-test
[ T{ dlist f f f 0 } ] [ <dlist> 1 over push-back dup pop-back* ] unit-test

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
[ f ] [ <dlist> 1 over push-back [ 2 = ] dlist-contains? ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] dlist-contains? ] unit-test

[ 1 ] [ <dlist> 1 over push-back [ 1 = ] delete-node-if ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dequeue-empty? ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dequeue-empty? ] unit-test
[ 0 ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dequeue-length ] unit-test
[ 1 ] [ <dlist> 1 over push-back 2 over push-back dup [ 1 = ] delete-node-if drop dequeue-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 1 = ] delete-node-if drop dequeue-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 2 = ] delete-node-if drop dequeue-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 3 = ] delete-node-if drop dequeue-length ] unit-test

[ 0 ] [ <dlist> dequeue-length ] unit-test
[ 1 ] [ <dlist> 1 over push-front dequeue-length ] unit-test
[ 0 ] [ <dlist> 1 over push-front dup pop-front* dequeue-length ] unit-test

[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 4 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 5 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back* [ = ] curry dlist-find-node drop class dlist-node = ] unit-test
[ ] [ <dlist> 4 over push-back 5 over push-back [ drop ] dlist-each ] unit-test

[ <dlist> peek-front ] [ empty-dlist? ] must-fail-with
[ <dlist> peek-back ] [ empty-dlist? ] must-fail-with
[ <dlist> pop-front ] [ empty-dlist? ] must-fail-with
[ <dlist> pop-back ] [ empty-dlist? ] must-fail-with
