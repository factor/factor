USING: arrays classes.algebra classes.algebra.private
classes.dispatch.covariant-tuples kernel math tools.test ;
IN: classes.dispatch.covariant-tuples.tests

{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ t } [ { tuple object } { tuple object } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ f } [ { tuple object } { tuple tuple } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ t } [ { tuple tuple } { tuple } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ f } [ { tuple } { tuple tuple } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ t } [ { tuple tuple } { object } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ f } [ { object object } { tuple } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ f } [ { object } { tuple tuple } [ <covariant-tuple> ] bi@ covariant-tuple<= ] unit-test
{ t } [ { tuple tuple } <covariant-tuple> tuple covariant-tuple<= ] unit-test
{ t } [ { tuple tuple } <covariant-tuple> object covariant-tuple<= ] unit-test
{ f } [ { tuple object } <covariant-tuple> tuple covariant-tuple<= ] unit-test
! { t } [ tuple { object tuple } <covariant-tuple> covariant-tuple<= ] unit-test
! { f } [ object { tuple object } <covariant-tuple> covariant-tuple<= ] unit-test
! { f } [ object { tuple tuple } <covariant-tuple> covariant-tuple<= ] unit-test
[ tuple { object tuple } <covariant-tuple> covariant-tuple<= ] must-fail
[ object { tuple object } <covariant-tuple> covariant-tuple<= ] must-fail
[ object { tuple tuple } <covariant-tuple> covariant-tuple<= ] must-fail
{ +incomparable+ } [ tuple { object tuple } compare-classes ] unit-test

{ t } [ { fixnum object } <covariant-tuple> { tuple tuple } <covariant-tuple> 2array
        <anonymous-union> covariant-tuple-union?
      ] unit-test

{ t } [ { fixnum object } <covariant-tuple> { tuple tuple } <covariant-tuple> 2array
        <anonymous-intersection> covariant-tuple-intersection?
      ] unit-test

{ T{ covariant-tuple f
   { union{ tuple fixnum } object } } }
[ union{ T{ covariant-tuple f { tuple object } } T{ covariant-tuple f { fixnum object } } }
  normalize-class ] unit-test

{ T{ covariant-tuple f
     { union{ tuple fixnum } object } } }
[ union{ T{ covariant-tuple f { tuple object } } T{ covariant-tuple f { fixnum object } } }
  normalize-class ] unit-test
