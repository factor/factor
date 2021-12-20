USING: arrays classes.algebra classes.algebra.private classes.dispatch
classes.dispatch.covariant-tuples classes.dispatch.eql kernel math tools.test
words ;
IN: classes.dispatch.eql.tests

{ t } [ fixnum <eql-specializer> word (class<=) ] unit-test
{ f } [ word fixnum <eql-specializer> (class<=) ] unit-test

{ t } [ fixnum <eql-specializer> fixnum <eql-specializer> (classes-intersect?) ] unit-test
{ f } [ float <eql-specializer> fixnum <eql-specializer> (classes-intersect?) ] unit-test

{ t } [ fixnum 2 <eql-specializer> (classes-intersect?) ] unit-test
{ f } [ float 2 <eql-specializer> (classes-intersect?) ] unit-test
{ t } [ number 2 <eql-specializer> (classes-intersect?) ] unit-test
{ f } [ array 2 <eql-specializer> (classes-intersect?) ] unit-test

{ t } [ 2 <eql-specializer> fixnum classes-intersect? ] unit-test
{ f } [ 2 <eql-specializer> float classes-intersect? ] unit-test
{ t } [ 2 <eql-specializer> number classes-intersect? ] unit-test
{ f } [ 2 <eql-specializer> array classes-intersect? ] unit-test


{ t } [ fixnum <eql-specializer> 1array <covariant-tuple> 0 swap nth-dispatch-class eql-specializer? ] unit-test
{ object } [ fixnum <eql-specializer> 1array <covariant-tuple> 1 swap nth-dispatch-class ] unit-test

{ tuple } [ fixnum <eql-specializer> tuple 2array <covariant-tuple> 0 swap nth-dispatch-class ] unit-test
{ t } [ fixnum <eql-specializer> tuple 2array <covariant-tuple> 1 swap nth-dispatch-class eql-specializer? ] unit-test
