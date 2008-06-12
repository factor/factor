IN: search-dequeues.tests
USING: search-dequeues tools.test namespaces
kernel sequences words dequeues vocabs ;

<hashed-dlist> "h" set

[ t ] [ "h" get dequeue-empty? ] unit-test

[ ] [ 3 "h" get push-front* "1" set ] unit-test
[ ] [ 1 "h" get push-front ] unit-test
[ ] [ 3 "h" get push-front* "2" set ] unit-test
[ ] [ 3 "h" get push-front* "3" set ] unit-test
[ ] [ 7 "h" get push-front ] unit-test

[ t ] [ "1" get "2" get eq? ] unit-test
[ t ] [ "2" get "3" get eq? ] unit-test

[ 3 ] [ "h" get dequeue-length ] unit-test
[ t ] [ 7 "h" get dequeue-member? ] unit-test

[ 3 ] [ "1" get node-value ] unit-test
[ ] [ "1" get "h" get delete-node ] unit-test

[ 2 ] [ "h" get dequeue-length ] unit-test
[ 1 ] [ "h" get pop-back ] unit-test
[ 7 ] [ "h" get pop-back ] unit-test

[ f ] [ 7 "h" get dequeue-member? ] unit-test

[ ] [
    <hashed-dlist>
    [ all-words swap [ push-front ] curry each ]
    [ [ drop ] slurp-dequeue ]
    bi
] unit-test
