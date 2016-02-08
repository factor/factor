USING: accessors arrays classes deques dlists kernel locals
math sequences tools.test ;
IN: dlists.tests

{ t } [ <dlist> deque-empty? ] unit-test

{ T{ dlist f T{ dlist-node f f f 1 } T{ dlist-node f f f 1 } } }
[ <dlist> 1 over push-front ] unit-test

! Make sure empty lists are empty
{ t } [ <dlist> deque-empty? ] unit-test
{ f } [ <dlist> 1 over push-front deque-empty? ] unit-test
{ f } [ <dlist> 1 over push-back deque-empty? ] unit-test

{ 1 } [ <dlist> 1 over push-front pop-front ] unit-test
{ 1 } [ <dlist> 1 over push-front pop-back ] unit-test
{ 1 } [ <dlist> 1 over push-back pop-front ] unit-test
{ 1 } [ <dlist> 1 over push-back pop-back ] unit-test
{ T{ dlist f f f } } [ <dlist> 1 over push-front dup pop-front* ] unit-test
{ T{ dlist f f f } } [ <dlist> 1 over push-front dup pop-back* ] unit-test
{ T{ dlist f f f } } [ <dlist> 1 over push-back dup pop-front* ] unit-test
{ T{ dlist f f f } } [ <dlist> 1 over push-back dup pop-back* ] unit-test

! Test the prev,next links for two nodes
{ f } [
    <dlist> 1 over push-back 2 over push-back
    front>> prev>>
] unit-test

{ 2 } [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> obj>>
] unit-test

{ 1 } [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> prev>> obj>>
] unit-test

{ f } [
    <dlist> 1 over push-back 2 over push-back
    front>> next>> next>>
] unit-test

{ f f } [ <dlist> [ 1 = ] dlist-find ] unit-test
{ 1 t } [ <dlist> 1 over push-back [ 1 = ] dlist-find ] unit-test
{ f f } [ <dlist> 1 over push-back [ 2 = ] dlist-find ] unit-test
{ f } [ <dlist> 1 over push-back [ 2 = ] dlist-any? ] unit-test
{ t } [ <dlist> 1 over push-back [ 1 = ] dlist-any? ] unit-test

{ 1 } [ <dlist> 1 over push-back [ 1 = ] delete-node-if ] unit-test
{ t } [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop deque-empty? ] unit-test
{ t } [ <dlist> 1 over push-back dup [ 1 = ] delete-node-if drop deque-empty? ] unit-test

{ t } [ <dlist> 4 over push-back 5 over push-back [ obj>> 4 = ] dlist-find-node class-of dlist-node = ] unit-test
{ t } [ <dlist> 4 over push-back 5 over push-back [ obj>> 5 = ] dlist-find-node class-of dlist-node = ] unit-test
{ t } [ <dlist> 4 over push-back 5 over push-back* [ = ] curry dlist-find-node class-of dlist-node = ] unit-test
{ } [ <dlist> 4 over push-back 5 over push-back [ drop ] dlist-each ] unit-test

{ f } [ <dlist> ?peek-front ] unit-test
{ 1 } [ <dlist> 1 over push-front ?peek-front ] unit-test
{ f } [ <dlist> ?peek-back ] unit-test
{ 1 } [ <dlist> 1 over push-back ?peek-back ] unit-test

[ <dlist> peek-front ] [ empty-deque? ] must-fail-with
[ <dlist> peek-back ] [ empty-deque? ] must-fail-with
[ <dlist> pop-front ] [ empty-deque? ] must-fail-with
[ <dlist> pop-back ] [ empty-deque? ] must-fail-with

{ t } [ <dlist> 3 over push-front 4 over push-back 3 swap deque-member? ] unit-test

{ f } [ <dlist> 3 over push-front 4 over push-back -1 swap deque-member? ] unit-test

{ f } [ <dlist> 0 swap deque-member? ] unit-test

! Make sure clone does the right thing
{ V{ 2 1 } V{ 2 1 3 } } [
    <dlist> 1 over push-front 2 over push-front
    dup clone 3 over push-back
    [ dlist>sequence ] bi@
] unit-test

{ V{ f 3 1 f } } [ <dlist> 1 over push-front 3 over push-front f over push-front f over push-back dlist>sequence ] unit-test

{ V{ } } [ <dlist> dlist>sequence ] unit-test

{ V{ 0 2 4 } } [ <dlist> { 0 1 2 3 4 } over push-all-back [ even? ] dlist-filter dlist>sequence ] unit-test
{ V{ 2 4 } } [ <dlist> { 1 2 3 4 } over push-all-back [ even? ] dlist-filter dlist>sequence ] unit-test
{ V{ 2 4 } } [ <dlist> { 1 2 3 4 5 } over push-all-back [ even? ] dlist-filter dlist>sequence ] unit-test
{ V{ 0 2 4 } } [ <dlist> { 0 1 2 3 4 5 } over push-all-back [ even? ] dlist-filter dlist>sequence ] unit-test

{ t } [ DL{ } DL{ } = ] unit-test
{ t } [ DL{ 1 } DL{ 1 } = ] unit-test
{ t } [ DL{ 1 2 } DL{ 1 2 } = ] unit-test
{ t } [ DL{ 1 1 } DL{ 1 1 } = ] unit-test
{ f } [ DL{ 1 2 3 } DL{ 1 2 } = ] unit-test
{ f } [ DL{ 1 2 } DL{ 1 2 3 } = ] unit-test
{ f } [ DL{ } DL{ 1 } = ] unit-test
{ f } [ DL{ f } DL{ 1 } = ] unit-test
{ f } [ f DL{ } = ] unit-test
{ f } [ DL{ } f = ] unit-test

TUPLE: my-node < dlist-link { obj fixnum } ;

: <my-node> ( obj -- node )
    my-node new
        swap >>obj ; inline

{ V{ 1 } } [ <dlist> 1 <my-node> over push-node-front dlist>sequence ] unit-test
{ V{ 2 1 } } [ <dlist> 1 <my-node> over push-node-front 2 <my-node> over push-node-front dlist>sequence ] unit-test

{ V{ 1 } } [ <dlist> 1 <my-node> over push-node-back dlist>sequence ] unit-test
{ V{ 1 2 } } [ <dlist> 1 <my-node> over push-node-back 2 <my-node> over push-node-back dlist>sequence ] unit-test
{ V{ 1 2 3 } } [ <dlist> 1 <my-node> over push-node-back 2 <my-node> over push-node-back 3 <my-node> over push-node-back dlist>sequence ] unit-test

: assert-links ( dlist-node -- )
    [ prev>> ] [ next>> ] bi 2array { f f } assert= ;

{ V{ } } [ <dlist> 1 <my-node> over push-node-back [ [ back>> ] [ ] bi delete-node ] [ ] bi dlist>sequence ] unit-test
[ V{ 1 2 } t ] [| |
    <dlist> :> dl
        1 <my-node> :> n1 n1 dl push-node-back
        2 <my-node> :> n2 n2 dl push-node-back
        3 <my-node> :> n3 n3 dl push-node-back

    n3 dl delete-node n3 assert-links
    dl dlist>sequence dup >dlist dl =
] unit-test

[ V{ 1 3 } t ] [| |
    <dlist> :> dl
        1 <my-node> :> n1 n1 dl push-node-back
        2 <my-node> :> n2 n2 dl push-node-back
        3 <my-node> :> n3 n3 dl push-node-back

    n2 dl delete-node n2 assert-links
    dl dlist>sequence dup >dlist dl =
] unit-test

[ V{ 2 3 } t ] [| |
    <dlist> :> dl
        1 <my-node> :> n1 n1 dl push-node-back
        2 <my-node> :> n2 n2 dl push-node-back
        3 <my-node> :> n3 n3 dl push-node-back

    n1 dl delete-node n1 assert-links
    dl dlist>sequence dup >dlist dl =
] unit-test


{ DL{ 0 1 2 3 4 } } [
    <dlist> [
        { 3 2 4 1 0 } [ swap push-sorted drop ] with each
    ] keep
] unit-test

{ 0 5 } [
    <dlist> dlist-length
    { 3 4 9 1 7 } >dlist dlist-length
] unit-test
