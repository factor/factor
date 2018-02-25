USING: deques dlists kernel namespaces sequences tools.test
vocabs ;

<hashed-dlist> "h" set

{ t } [ "h" get deque-empty? ] unit-test

{ } [ 3 "h" get push-front* "1" set ] unit-test
{ } [ 1 "h" get push-front ] unit-test
{ } [ 3 "h" get push-front* "2" set ] unit-test
{ } [ 3 "h" get push-front* "3" set ] unit-test
{ } [ 7 "h" get push-front ] unit-test

{ t } [ "1" get "2" get eq? ] unit-test
{ t } [ "2" get "3" get eq? ] unit-test

{ t } [ 7 "h" get deque-member? ] unit-test

{ 3 } [ "1" get node-value ] unit-test
{ } [ "1" get "h" get delete-node ] unit-test

{ 1 } [ "h" get pop-back ] unit-test
{ 7 } [ "h" get pop-back ] unit-test

{ f } [ 7 "h" get deque-member? ] unit-test

{ } [
    <hashed-dlist>
    [ all-words swap [ push-front ] curry each ]
    [ [ drop ] slurp-deque ]
    bi
] unit-test
