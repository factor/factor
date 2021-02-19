USING: arrays classes.dispatch classes.dispatch.covariant-tuples
classes.dispatch.eql kernel math tools.test words ;
IN: classes.dispatch.eql.tests


! { word } [ fixnum <eql-specializer> 0 swap nth-dispatch-class ] unit-test
! { object } [ fixnum <eql-specializer> 1 swap nth-dispatch-class ] unit-test
! { t } [ word fixnum <eql-specializer> 0 swap nth-dispatch-applicable? ] unit-test
! { f } [ number fixnum <eql-specializer> 0 swap nth-dispatch-applicable? ] unit-test
! { t } [ word fixnum <eql-specializer> 1 swap nth-dispatch-applicable? ] unit-test
! { t } [ number fixnum <eql-specializer> 1 swap nth-dispatch-applicable? ] unit-test


{ t } [ fixnum <eql-specializer> 1array <covariant-tuple> 0 swap nth-dispatch-class eql-specializer? ] unit-test
{ object } [ fixnum <eql-specializer> 1array <covariant-tuple> 1 swap nth-dispatch-class ] unit-test

{ tuple } [ fixnum <eql-specializer> tuple 2array <covariant-tuple> 0 swap nth-dispatch-class ] unit-test
{ t } [ fixnum <eql-specializer> tuple 2array <covariant-tuple> 1 swap nth-dispatch-class eql-specializer? ] unit-test
