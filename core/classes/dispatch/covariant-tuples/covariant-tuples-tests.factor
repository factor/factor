USING: arrays classes.algebra classes.algebra.private classes.dispatch
classes.dispatch.covariant-tuples kernel math sequences tools.test ;
IN: classes.dispatch.covariant-tuples.tests

{ fixnum } [ { tuple fixnum } <covariant-tuple> 0 swap nth-dispatch-class ] unit-test
{ tuple } [ { tuple fixnum } <covariant-tuple> 1 swap nth-dispatch-class ] unit-test

{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ t } [ { tuple object } { tuple object } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ f } [ { tuple object } { tuple tuple } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ t } [ { tuple tuple } { tuple } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ f } [ { tuple } { tuple tuple } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ t } [ { tuple tuple } { object } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ f } [ { object object } { tuple } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ f } [ { object } { tuple tuple } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test

! Comparisons between classes and dispatch-types
! { f } [ { tuple tuple } <covariant-tuple> tuple covariant-tuple<= ] unit-test
! { f } [ { tuple tuple } <covariant-tuple> object covariant-tuple<= ] unit-test
! { f } [ { tuple object } <covariant-tuple> tuple covariant-tuple<= ] unit-test

{ f } [ { tuple tuple } <covariant-tuple> tuple left-dispatch<= ] unit-test
{ f } [ { tuple tuple } <covariant-tuple> object left-dispatch<= ] unit-test
{ f } [ { tuple object } <covariant-tuple> tuple left-dispatch<= ] unit-test

{ f } [ tuple { object tuple } <covariant-tuple> right-dispatch<= ] unit-test
{ f } [ object { tuple object } <covariant-tuple> right-dispatch<= ] unit-test
{ f } [ object { tuple tuple } <covariant-tuple> right-dispatch<= ] unit-test

! Same with class<=
! Debugging strange error: walking was working, running compiled not.  Turns out that classes.algebra had not been calling dispatch<=
{ { tuple tuple } { tuple object } } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ covariant-classes ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ covariant-classes [ (class<=) ] 2all? ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ covariant-classes [ class<= ] 2all? ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ left-dispatch<= ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ right-dispatch<= ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ [ dispatch-type? ] both? ] unit-test
{ t } [ { tuple tuple } { tuple object } [ <covariant-tuple> ] bi@ (class<=) ] unit-test

{ t } [ { tuple object } { tuple object } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ f } [ { tuple object } { tuple tuple } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ t } [ { tuple tuple } { tuple } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ f } [ { tuple } { tuple tuple } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ t } [ { tuple tuple } { object } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ f } [ { object object } { tuple } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ f } [ { object } { tuple tuple } [ <covariant-tuple> ] bi@ (class<=) ] unit-test
{ f } [ { tuple tuple } <covariant-tuple> tuple (class<=) ] unit-test
{ t } [ { tuple tuple } <covariant-tuple> object (class<=) ] unit-test
{ f } [ { tuple object } <covariant-tuple> tuple (class<=) ] unit-test

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
