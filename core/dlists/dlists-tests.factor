USING: dlists dlists.private kernel tools.test random assocs
sets sequences namespaces sorting debugger io prettyprint
math accessors classes ;
IN: dlists.tests

[ t ] [ <dlist> dlist-empty? ] unit-test

[ T{ dlist f T{ dlist-node f 1 f f } T{ dlist-node f 1 f f } 1 } ]
[ <dlist> 1 over push-front ] unit-test

! Make sure empty lists are empty
[ t ] [ <dlist> dlist-empty? ] unit-test
[ f ] [ <dlist> 1 over push-front dlist-empty? ] unit-test
[ f ] [ <dlist> 1 over push-back dlist-empty? ] unit-test

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
    dlist-front dlist-node-prev
] unit-test

[ 2 ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-obj
] unit-test

[ 1 ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-prev dlist-node-obj
] unit-test

[ f ] [
    <dlist> 1 over push-back 2 over push-back
    dlist-front dlist-node-next dlist-node-next
] unit-test

[ f f ] [ <dlist> [ 1 = ] dlist-find ] unit-test
[ 1 t ] [ <dlist> 1 over push-back [ 1 = ] dlist-find ] unit-test
[ f f ] [ <dlist> 1 over push-back [ 2 = ] dlist-find ] unit-test
[ f ] [ <dlist> 1 over push-back [ 2 = ] dlist-contains? ] unit-test
[ t ] [ <dlist> 1 over push-back [ 1 = ] dlist-contains? ] unit-test

[ 1 ] [ <dlist> 1 over push-back [ 1 = ] delete-node-if ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dlist-empty? ] unit-test
[ t ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dlist-empty? ] unit-test
[ 0 ] [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop dlist-length ] unit-test
[ 1 ] [ <dlist> 1 over push-back 2 over push-back dup [ 1 = ] delete-node-if drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 1 = ] delete-node-if drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 2 = ] delete-node-if drop dlist-length ] unit-test
[ 2 ] [ <dlist> 1 over push-back 2 over push-back 3 over push-back dup [ 3 = ] delete-node-if drop dlist-length ] unit-test

[ 0 ] [ <dlist> dlist-length ] unit-test
[ 1 ] [ <dlist> 1 over push-front dlist-length ] unit-test
[ 0 ] [ <dlist> 1 over push-front dup pop-front* dlist-length ] unit-test

: assert-same-elements
    [ prune natural-sort ] bi@ assert= ;

: dlist-delete-all [ dlist-delete drop ] curry each ;

: dlist>array [ [ , ] dlist-slurp ] { } make ;

[ ] [
    5 [ drop 30 random >fixnum ] map prune
    6 [ drop 30 random >fixnum ] map prune [
        <dlist>
        [ push-all-front ]
        [ dlist-delete-all ]
        [ dlist>array ] tri
    ] 2keep swap diff assert-same-elements
] unit-test

[ ] [
    <dlist> "d" set
    1 "d" get push-front
    2 "d" get push-front
    3 "d" get push-front
    4 "d" get push-front
    2 "d" get dlist-delete drop
    3 "d" get dlist-delete drop
    4 "d" get dlist-delete drop
] unit-test

[ 1 ] [ "d" get dlist-length ] unit-test
[ 1 ] [ "d" get dlist>array length ] unit-test

[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 4 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back [ obj>> 5 = ] dlist-find-node drop class dlist-node = ] unit-test
[ t ] [ <dlist> 4 over push-back 5 over push-back* [ = ] curry dlist-find-node drop class dlist-node = ] unit-test
[ ] [ <dlist> 4 over push-back 5 over push-back [ drop ] dlist-each ] unit-test

[ f ] [ <dlist> peek-front ] unit-test
[ f ] [ <dlist> peek-back ] unit-test
