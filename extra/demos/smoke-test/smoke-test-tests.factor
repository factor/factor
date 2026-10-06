USING: demos.smoke-test tools.test ;
IN: demos.smoke-test.tests

! Every Demos menu entry must have an explicit audit category.
{ } [ check-demo-coverage ] unit-test
