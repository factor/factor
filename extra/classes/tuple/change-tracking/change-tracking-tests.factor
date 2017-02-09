USING: classes.tuple.change-tracking tools.test strings accessors kernel continuations ;
IN: classes.tuple.change-tracking.tests

TUPLE: resource < change-tracking-tuple
    { pathname string } ;

: <resource> ( pathname -- resource ) f swap resource boa ;

{ t } [ "foo" <resource> "bar" >>pathname changed?>> ] unit-test
{ f } [ "foo" <resource> [ 123 >>pathname ] ignore-errors changed?>> ] unit-test
