USING: tools.test math arrays project-euler.ave-time ;

{ 0 3 } [ 1 2 [ + ] 10 collect-benchmarks ] must-infer-as
{ 1 2 t } [ 1 2 [ + ] 10 collect-benchmarks array? ] unit-test
